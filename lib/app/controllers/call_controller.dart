import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  // Remove
  final RxString outGoingCallStatus = 'Requesting...'.obs;

  final SocketController socketController = Get.find<SocketController>();

  final Rx<CallModel?> activeCall = Rx<CallModel?>(null);

  bool isWatcherLoaded = false;

  AudioPlayer audioPlayer = AudioPlayer();

  Room? room;
  EventsListener<RoomEvent>? listener;

  final RxBool isMuted = false.obs;

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
    audioPlayer.dispose();
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

  void startOutgoingCall(UserModel user) {
    debugPrint('CallController: Starting outgoing call to ${user.displayName}');

    // Check if the call already exists
    if (calls.any(
      (call) =>
          call.type == CallType.individual && call.participants.contains(user),
    )) {
      debugPrint('CallController: Call already exists');
      return;
    }

    // Get Call ID

    sendEvent('request', user.id, null, (resp) {
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
      room = Room(
        roomOptions: RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultAudioPublishOptions: const AudioPublishOptions(
            name: 'audio_track',
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
