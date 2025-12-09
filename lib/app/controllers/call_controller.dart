import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:talkliner/app/config/app_config.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/controllers/socket_controller.dart';
import 'package:talkliner/app/models/call_model.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/views/calling/call_screen.dart';

class CallController extends GetxController {
  // Calls List
  final RxList<CallModel> calls = <CallModel>[].obs;

  static const platform = MethodChannel('com.steigenberg.talkliner/pip');

  Future<void> _updateAutoPip(bool enable) async {
    try {
      if (Platform.isAndroid) {
        if (enable) {
          await platform.invokeMethod('enableAutoPip');
        } else {
          await platform.invokeMethod('disableAutoPip');
        }
      }
    } catch (e) {
      debugPrint("Failed to update PIP state: $e");
    }
  }

  // Remove
  final RxString outGoingCallStatus = 'Requesting...'.obs;

  final SocketController socketController = Get.find<SocketController>();

  final Rx<CallModel?> activeCall = Rx<CallModel?>(null);

  bool isWatcherLoaded = false;

  AudioPlayer audioPlayer = AudioPlayer();

  Room? room;
  EventsListener<RoomEvent>? listener;

  final RxBool isMuted = false.obs;
  final RxBool isSpeakerOn = false.obs;
  final RxString durationString = '00:00'.obs;
  Timer? _callTimer;
  int _callDurationSeconds = 0;

  final RxBool isVideoEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    socketController.isConnected.listen((value) {
      if (value && !isWatcherLoaded) {
        watchEvents();
        isWatcherLoaded = true;
      }
    });
  }

  @override
  void onClose() {
    _updateAutoPip(false);
    audioPlayer.dispose();
    _callTimer?.cancel();
    room?.dispose();
    super.onClose();
  }

  void watchEvents() {
    socketController.on(
      'audiocall:incoming',
      (resp) => handleIncomingCall(resp),
    );
    socketController.on('audiocall:ended', (resp) => handleCallEnded(resp));
    socketController.on(
      'audiocall:rejected',
      (resp) => handleCallRejected(resp),
    );

    socketController.on(
      'audiocall:accepted',
      (resp) => handleCallAccepted(resp),
    );
  }

  void sendEvent(type, to, data, Function cb) {
    if (socketController.isConnected.value) {
      final UserModel user = Get.find<AuthController>().user.value!;
      socketController.emitWithAck(
        'audiocall:$type',
        {'to': to, 'from': user.id, 'event': "audiocall:$type", 'data': data},
        (response) {
          debugPrint('CallController: Response: $response');
          cb(response);
        },
      );
    } else {
      debugPrint('CallController: Socket not connected');
    }
  }

  void startOutgoingCall(UserModel user, {bool isVideo = false}) {
    debugPrint('CallController: Starting outgoing call to ${user.displayName}');

    // Update video state
    isVideoEnabled.value = isVideo;

    // Check if the call already exists
    if (calls.any(
      (call) =>
          call.type == CallType.individual && call.participants.contains(user),
    )) {
      debugPrint('CallController: Call already exists');
      return;
    }

    // Get Call ID
    sendEvent('request', user.id, {'isVideo': isVideo}, (resp) {
      debugPrint('CallController: Response: $resp');
      CallModel call = CallModel.make(
        callId: resp['call_id'],
        roomID: resp['room']?['roomName'] ?? '',
        roomToken: resp['room']?['token'] ?? '',
        direction: CallDirection.outgoing,
        type: CallType.individual,
        status: CallStatus.calling,
        participants: [user],
        sendEvent: sendEvent,
      );

      // Add to calls list
      addCall(call);

      // Make it the active call
      activeCall.value = call;
    });
  }

  void retryCall() {}

  void handleCallAccepted(resp) {
    debugPrint('CallController: Call accepted: $resp');
    try {
      if (resp['call_id'] != null) {
        CallModel call = calls.firstWhere((c) => c.id == resp['call_id']);
        call.updateStatus(CallStatus.accepted);

        activeCall.refresh();

        // Initiator connects here because they already have the token from request
        if (call.roomToken.isNotEmpty) {
          connectToRoom(call.roomToken);

          // if outgoing screen is opened, it will be closed
          if (Get.currentRoute == '/OutgoingCallScreen') {
            Get.back();
          }

          Get.to(() => CallScreen());
        }
      }
    } catch (e) {
      debugPrint('CallController: Call accepted: $e');
    }
  }

  Future<void> connectToRoom(String token) async {
    try {
      // Initialize timer display state immediately
      durationString.value = '00:00';

      room = Room(
        roomOptions: RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultAudioPublishOptions: const AudioPublishOptions(
            name: 'audio_track',
          ),
          defaultVideoPublishOptions: const VideoPublishOptions(
            name: 'video_track',
          ),
        ),
      );

      listener = room!.createListener();

      // Audio setup (defaulting to speaker for testing, can be toggled)
      // await room!.prepareConnection();

      await room!.connect(AppConfig.livekitUrl, token);

      // Enable microphone
      await room!.localParticipant?.setMicrophoneEnabled(true);
      isMuted.value = false;

      // Enable Camera if video is enabled
      await room!.localParticipant?.setCameraEnabled(isVideoEnabled.value);

      if (isVideoEnabled.value) {
        _updateAutoPip(true);
      }

      // Start Timer
      startTimer();

      // Check initial speaker state (default is usually earpiece or system default, but we can enforce)
      // For now, let's assume default and user can toggle.
      // Or we can try to detecting it.
      // Hardware.instance.setSpeakerphoneOn(false); // Default to earpiece?

      debugPrint('CallController: Connected to LiveKit room');

      listener!.on((event) {
        debugPrint('CallController: Room event: $event');
      });

      // Stop Ringtone if playing
      audioPlayer.stop();
    } catch (e) {
      debugPrint('CallController: Failed to connect to room: $e');
      Fluttertoast.showToast(msg: 'Failed to connect to call');
    }
  }

  Future<void> disconnectRoom() async {
    if (room != null) {
      await room!.disconnect();
      room = null;
    }
    _updateAutoPip(false);
    stopTimer();
    audioPlayer.stop();
  }

  void toggleMute() async {
    if (room != null && room!.localParticipant != null) {
      // livekit_client 2.0+ uses isMicrophoneEnabled as a synchronous check or helper
      // but commonly we just track state or use value.

      // Correct logic:
      // current: isMuted=false (mic on). Toggle -> isMuted=true (mic off).
      // setMicrophoneEnabled(false).

      await room!.localParticipant?.setMicrophoneEnabled(isMuted.value);
      isMuted.value = !isMuted.value;
    }
  }

  CameraPosition cameraPosition = CameraPosition.front;

  void toggleVideo() async {
    if (room != null && room!.localParticipant != null) {
      isVideoEnabled.value = !isVideoEnabled.value;
      await room!.localParticipant?.setCameraEnabled(isVideoEnabled.value);
      _updateAutoPip(isVideoEnabled.value);
    }
  }

  void flipCamera() async {
    if (room != null && room!.localParticipant != null) {
      final publication =
          room!.localParticipant!.videoTrackPublications.firstOrNull;
      if (publication?.track is LocalVideoTrack) {
        final track = publication!.track as LocalVideoTrack;
        final newPosition =
            cameraPosition == CameraPosition.front
                ? CameraPosition.back
                : CameraPosition.front;

        await track.restartTrack(
          CameraCaptureOptions(cameraPosition: newPosition),
        );
        cameraPosition = newPosition;
      }
    }
  }

  void toggleSpeaker() async {
    isSpeakerOn.value = !isSpeakerOn.value;
    await Hardware.instance.setSpeakerphoneOn(isSpeakerOn.value);
  }

  void startTimer() {
    _callDurationSeconds = 0;
    durationString.value = '00:00';
    _callTimer?.cancel();
    _callTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _callDurationSeconds++;
      int minutes = _callDurationSeconds ~/ 60;
      int seconds = _callDurationSeconds % 60;
      durationString.value =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    });
  }

  void stopTimer() {
    _callTimer?.cancel();
    _callTimer = null;
    durationString.value = '';
  }

  // End Call
  void endCall(call) {
    call.endCall((resp) {
      // Call is Ended
      disconnectRoom();

      // Remove from calls list
      calls.remove(call);

      // Show Toast
      Fluttertoast.showToast(msg: 'Call ended');

      // Remove from active call
      activeCall.value = null;

      // Close Call Screen
      Get.back();
    });
  }

  void addCall(CallModel call) {
    // Check if the call already exists
    if (calls.any((c) => c.id == call.id)) {
      debugPrint('CallController: Call already exists');
      return;
    }

    calls.add(call);
  }

  // Handle Incoming Call
  void handleIncomingCall(resp) {
    if (resp['call_id'] != null) {
      CallModel call = CallModel.make(
        callId: resp['call_id'],
        roomID: resp['room']?['roomName'] ?? '',
        roomToken: resp['room']?['token'] ?? '',
        direction: CallDirection.incoming,
        type: CallType.individual,
        status: CallStatus.pending,
        participants: [UserModel.fromJson(resp['from'])],
        sendEvent: sendEvent,
      );

      // Add to calls list
      addCall(call);

      // Play ringtone
      playRingtone();

      // Show Popup
      call.showPopup(
        () {
          // Stop Audio
          audioPlayer.stop();
          // Get parent of the class
          Get.find<CallController>().removeCall(call);
        },
        (response) {
          audioPlayer.stop();
          if (response != null && response['roomAccessToken'] != null) {
            String? token = response['roomAccessToken']['token'];
            if (token != null) {
              call.updateRoomID(response['roomName']);
              call.updateRoomToken(token);
              call.updateStatus(CallStatus.accepted);
              activeCall.value = call;
              activeCall.value?.updateStatus(CallStatus.accepted);
              activeCall.refresh();
              connectToRoom(token);
              Get.to(() => CallScreen());
            }
          }
        },
      );

      // debugPrint('CallController: Incoming call: $call');
    }
  }

  void playRingtone() {
    // Play ringtone in a loop
    audioPlayer.setVolume(1.0);
    audioPlayer.play(AssetSource('audio/talkliner-ringtone.mp3'));
    audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  // Handle Call Ended
  void handleCallEnded(resp) {
    debugPrint('CallController: Call ended: $resp');
    if (resp['call_id'] != null) {
      CallModel call = calls.firstWhere((c) => c.id == resp['call_id']);

      while (Get.isDialogOpen! || Get.isBottomSheetOpen!) {
        Get.back();
      }

      if (resp['initiator_id'] != Get.find<AuthController>().user.value!.id) {
        Fluttertoast.showToast(
          msg: 'Call ended by ${call.participants.first.displayName}',
        );
      }

      // Remove from calls list
      removeCall(call);
      disconnectRoom();

      // If this was the active call, close the screen
      // Assuming CallScreen is the top route or we want to exit it
      if (Get.currentRoute == '/CallScreen' || !Get.isDialogOpen!) {
        // Identifying if we are on CallScreen is tricky without named routes.
        // But usually we want to pop if the active call ended.
        Get.back();
      }
    }
  }

  // Handle Call Rejected
  void handleCallRejected(resp) {
    try {
      if (resp['call_id'] != null) {
        while (Get.isDialogOpen! || Get.isBottomSheetOpen!) {
          Get.back();
        }
        if (Get.currentRoute == '/OutgoingCallScreen') {
          CallModel call = calls.firstWhere((c) => c.id == resp['call_id']);

          // Get current route in Getx
          debugPrint('CallController: Current route: ${Get.currentRoute}');

          Get.back();

          Fluttertoast.showToast(
            msg: 'Call rejected by ${call.participants.first.displayName}',
          );

          removeCall(call);
        }
      }
    } catch (e) {
      debugPrint('CallController: Call rejected: $e');
    }
  }

  // Remove Call
  removeCall(CallModel call) {
    calls.remove(call);
    if (activeCall.value?.id == call.id) {
      activeCall.value = null;
    }
  }
}
