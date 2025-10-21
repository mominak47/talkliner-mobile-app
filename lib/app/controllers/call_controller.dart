import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/controllers/socket_controller.dart';
import 'package:talkliner/app/models/call_model.dart';
import 'package:talkliner/app/models/user_model.dart';

class CallController extends GetxController {
  // Calls List
  final RxList<CallModel> calls = <CallModel>[].obs;

  // Remove
  final RxString outGoingCallStatus = 'Requesting...'.obs;

  final SocketController socketController = Get.find<SocketController>();

  final Rx<CallModel?> activeCall = Rx<CallModel?>(null);

  bool isWatcherLoaded = false;

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

  void watchEvents() {
    socketController.on(
      'audiocall:incoming',
      (resp) => handleIncomingCall(resp),
    );
    socketController.on('audiocall:ended', (resp) => handleCallEnded(resp));
    socketController.on('audiocall:rejected', (resp) => handleCallRejected(resp));
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

  // End Call
  void endCall(call) {
    call.endCall((resp) {
      // Call is Ended

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

      // Show Popup
      call.showPopup();

      // Add to calls list
      addCall(call);

      debugPrint('CallController: Incoming call: $call');
    }
  }

  // Handle Call Ended
  void handleCallEnded(resp) {
    debugPrint('CallController: Call ended: $resp');
    if (resp['call_id'] != null) {
      CallModel call = calls.firstWhere((c) => c.id == resp['call_id']);

      while (Get.isDialogOpen! || Get.isBottomSheetOpen!) {
        Get.back();
      }

      if(resp['initiator_id'] != Get.find<AuthController>().user.value!.id){
        Fluttertoast.showToast(msg: 'Call ended by ${call.participants.first.displayName}');
      }

      // Remove from calls list
      removeCall(call);
    }
  }

  // Handle Call Rejected
  void handleCallRejected(resp) {
    debugPrint('CallController: Call rejected: $resp');
    if (resp['call_id'] != null) {
      CallModel call = calls.firstWhere((c) => c.id == resp['call_id']);

      while (Get.isDialogOpen! || Get.isBottomSheetOpen!) {
        Get.back();
      }

      Fluttertoast.showToast(msg: 'Call rejected by ${call.participants.first.displayName}');

      removeCall(call);
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
