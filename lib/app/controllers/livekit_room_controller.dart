import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/config/app_config.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/services/api_service.dart';

class LivekitRoomController extends GetxController {
  AuthController authController = Get.find<AuthController>();

  final apiService = ApiService();
  final RxBool isConnected = false.obs;
  final RxBool isRoomConnecting = false.obs;
  final RxString roomName = ''.obs;
  EventsListener<RoomEvent>? _listener;

  final _audioPlayer = AudioPlayer();

  Room? _room;

  Room? getRoom() {
    if (_room == null) {
      return null;
    }

    return _room;
  }

  @override
  onInit() {
    super.onInit();
    apiService.onInit();
    authController.isLoggedIn.listen(
      (isLoggedIn) => !isLoggedIn ? disconnectFromRoom() : null,
    );
  }

  Future<String> getLivekitToken(String roomName) async {
    final response = await apiService.post('/livekit', {'chatId': roomName});

    if (response.body['success'] == true) {
      return response.body['token']['token'];
    }

    return throw Exception(response.body);
  }

  Future<String> getChatId(UserModel user) async {
    final response = await apiService.get('/chats/get_chat_id/${user.id}');
    if (response.statusCode == 200) {
      return response.body['data']['chat_id'];
    }

    debugPrint("Error: ${response.body}");
    return '';
  }

  Future<void> connectToRoom(UserModel user) async {
    try {
      // Check if room is already connected
      if (isConnected.value) {
        await disconnectFromRoom();
      }
      if (user.id.isEmpty) {
        return;
      }
      String chatId = await getChatId(user);

      debugPrint("Chat ID: $chatId");
      isRoomConnecting.value = true;

      String token = await getLivekitToken("ptt_$chatId");
      _room = Room(roomOptions: getRoomOptions());

      _listener = _room?.createListener();

      _setupRoomEventListeners();

      await _room!.connect(AppConfig.livekitUrl, token);
    } catch (e) {
      debugPrint('Error connecting to room: $e');
    }
  }

  void _setupRoomEventListeners() {
    _listener!
      ..on<RoomConnectedEvent>(_onRoomConnected)
      ..on<RoomDisconnectedEvent>(_onRoomDisconnected)
      ..on<ParticipantConnectedEvent>(_onParticipantConnected)
      ..on<ParticipantDisconnectedEvent>(_onParticipantDisconnected)
      ..on<TrackPublishedEvent>(_onTrackPublished)
      ..on<TrackUnpublishedEvent>(_onTrackUnpublished)
      ..on<TrackSubscribedEvent>(_onTrackSubscribed)
      ..on<TrackUnsubscribedEvent>(_onTrackUnsubscribed)
      ..on<DataReceivedEvent>(_onDataReceived);
  }

  Future<void> disconnectFromRoom() async {
    if (_room == null) return;
    await _room!.disconnect();
    _room = null;
    _listener?.dispose();
    _listener = null;
  }

  RoomOptions getRoomOptions() {
    return RoomOptions(
      adaptiveStream: true,
      dynacast: true,
      defaultAudioPublishOptions: AudioPublishOptions(name: "PTT"),
    );
  }

  void _onRoomConnected(RoomConnectedEvent event) {
    debugPrint('\nConnected to room : ${event.room.name}');
    isConnected.value = true;
    isRoomConnecting.value = false;

    // Play PTT Connect Sound
    _audioPlayer.play(AssetSource('audio/ptt-connect.wav'));
  }

  void _onRoomDisconnected(RoomDisconnectedEvent event) {
    debugPrint('\nDisconnected from room');
    debugPrint(event.toString());
    isConnected.value = false;
  }

  void _onParticipantConnected(ParticipantConnectedEvent event) {
    debugPrint('\nParticipant connected: ${event.participant.identity}');
  }

  void _onParticipantDisconnected(ParticipantDisconnectedEvent event) {
    debugPrint('\nParticipant disconnected: ${event.participant.identity}');
  }

  void _onTrackPublished(TrackPublishedEvent event) {
    debugPrint('\nTrack published: ${event.publication.kind}');
  }

  void _onTrackUnpublished(TrackUnpublishedEvent event) {
    debugPrint('\nTrack unpublished: ${event.publication.kind}');
  }

  void _onTrackSubscribed(TrackSubscribedEvent event) {
    debugPrint('\nTrack subscribed: ${event.track.kind}');
  }

  void _onTrackUnsubscribed(TrackUnsubscribedEvent event) {
    debugPrint('\nTrack unsubscribed: ${event.track.kind}');
  }

  void _onDataReceived(DataReceivedEvent event) {
    try {
      final data = jsonDecode(utf8.decode(event.data));
      debugPrint('\nData received: $data');
    } catch (e) {
      debugPrint('\nError parsing received data: $e');
    }
  }

  Future<void> speak() async {
    _room?.localParticipant?.setMicrophoneEnabled(true);
    await sendEvent(
      jsonEncode({
        'type': 'individual',
        'from': authController.user.value?.id ?? '',
      }),
      "ptt-speaking-start",
    );
  }

  Future<void> stopSpeaking() async {
    _room?.localParticipant?.setMicrophoneEnabled(false);

    await sendEvent(
      jsonEncode({
        'type': 'individual',
        'from': authController.user.value?.id ?? '',
      }),
      "ptt-speaking-end",
    );
  }

  Future<void> sendEvent(String event, String type) async {
    if (_room == null) return;
    if (_room!.connectionState != ConnectionState.connected) return;

    try {
      await _room!.localParticipant!
          .publishData(utf8.encode(jsonEncode({'event': event, 'type': type})))
          .timeout(
            Duration(seconds: 5),
            onTimeout: () {
              debugPrint('\nPushToTalkService: Timeout sending event to room');
              throw TimeoutException('Failed to send event');
            },
          );
      debugPrint('\nPushToTalkService: Event sent successfully: $type');
    } catch (e) {
      debugPrint('\nPushToTalkService: Error sending event to room: $e');
    }
  }
}
