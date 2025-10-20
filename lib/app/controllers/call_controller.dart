import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/controllers/layout_controller.dart';
import 'package:talkliner/app/controllers/socket_controller.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';

class CallController extends GetxController {
  final RxBool incomingCall = false.obs;
  final RxBool outgoingCall = false.obs;
  final RxBool callEnded = false.obs;
  final RxString outGoingCallStatus = 'Requesting...'.obs;

  final Rx<UserModel> onCallWithUser = UserModel.fromJson({}).obs;
  final RxString onCallRoomID = ''.obs;
  final RxString onCallRoomToken = ''.obs;
  final RxString onCallID = ''.obs;

  final _audioPlayer = AudioPlayer();

  final SocketController socketController = Get.find<SocketController>();
  final LayoutController layoutController = Get.find<LayoutController>();

  @override
  void onInit() {
    super.onInit();

    socketController.isConnected.listen((isConnected) {
      if (isConnected) {
        socketListener();
      }
    });
  }

  void socketListener() {
    socketController.on('audiocall:ended:timeout', (resp) {
      debugPrint('CallController: Ended timeout event received: $resp');

      debugPrint('CallController: Call ID: ${resp['call_id']}');
      debugPrint('CallController: On Call ID: ${onCallID.value}');
      try {
        if (resp['call_id'] == onCallID.value) {
          endCallDueToTimeout();
        }
      } catch (e) {
        debugPrint('CallController: Error receiving ended timeout: $e');
      }
    });

    // Handle Incoming Call
    socketController.on('audiocall:incoming', (resp) => handleIncomingCall(resp));
  }

  // Dispose
  @override
  void onClose() {
    _audioPlayer.stop();
    super.onClose();
    _audioPlayer.dispose();
  }

  void retryCall(){
    startOutgoingCall(onCallWithUser.value);
  }

  void endCallDueToTimeout(){
    debugPrint('CallController: Ending call due to timeout!!!!!!');
    _audioPlayer.stop();
    _audioPlayer.play(AssetSource('audio/disconnect.mp3'));
    _audioPlayer.setReleaseMode(ReleaseMode.release);
    outGoingCallStatus.value = "No Answer";
    onCallID.value = '';
    onCallRoomID.value = '';
    onCallRoomToken.value = '';
    callEnded.value = true;
  }

  void sendEvent(type, to, data, Function cb) {
    if (socketController.isConnected.value) {
      final UserModel user = Get.find<AuthController>().user.value!;
      debugPrint('CallController: Sending event: audiocall:$type');
      socketController.emitWithAck(
        'audiocall:$type',
        {'to': to, 'from': user.id, 'event': "audiocall:$type", 'data': data},
        (response) {
          cb(response);
        },
      );
    } else {
      debugPrint('CallController: Socket not connected');
    }
  }

  void showPopup(UserModel user) {
    debugPrint('CallController: Showing popup');
    bool isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;

    // Play ringtone
    _audioPlayer.play(AssetSource('audio/talkliner-ringtone.mp3'));
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        backgroundColor:
            isDarkMode
                ? TalklinerThemeColors.gray800
                : TalklinerThemeColors.gray020,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatar(user: user, size: 100, indicator: false),
            SizedBox(height: 20),
            Text(
              user.displayName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Incoming call..',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            ),
          ],
        ),
        actions: [
          CircleAvatar(
            radius: 32,
            backgroundColor: TalklinerThemeColors.green500,
            child: IconButton(
              iconSize: 24,
              onPressed: () {
                _audioPlayer.stop();
                showOnCallBar();
                Get.back();
              },
              icon: Icon(LucideIcons.check, color: Colors.white),
            ),
          ),
          CircleAvatar(
            radius: 32,
            backgroundColor: TalklinerThemeColors.red500,
            child: IconButton(
              iconSize: 24,
              onPressed: () {
                _audioPlayer.stop();
                _audioPlayer.play(AssetSource('audio/disconnect.mp3'));
                _audioPlayer.setReleaseMode(ReleaseMode.release);
                Get.back();
              },
              icon: Icon(LucideIcons.x, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void showOnCallBar() {
    Widget onCallBar = Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(color: TalklinerThemeColors.green400),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Momin Khan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TalklinerThemeColors.gray900,
                  ),
                ),
                Text(
                  "02:33",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: TalklinerThemeColors.gray900,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TalklinerThemeColors.red500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    debugPrint('CallController: Ending call');
                    _audioPlayer.stop();
                    _audioPlayer.play(AssetSource('audio/disconnect.mp3'));
                    _audioPlayer.setReleaseMode(ReleaseMode.release);
                    layoutController.removeAction(
                      'recent_screen',
                      'on_call_bar',
                    );
                  },
                  child: Text("End"),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    layoutController.addAction(
      'recent_screen',
      () => onCallBar,
      id: 'on_call_bar',
    );
  }

  void startIncomingCall() {
    incomingCall.value = true;
  }

  void startOutgoingCall(UserModel user) {
    debugPrint('CallController: Starting outgoing call to ${user.displayName}');
    onCallWithUser.value = user;
    _audioPlayer.stop();
    _audioPlayer.setVolume(1.0);

    outGoingCallStatus.value = "Calling..";

    // Tell the callee that we are calling them
    sendEvent('request', onCallWithUser.value.id, null, (resp) {
      // Get Room ID
      onCallID.value = resp['call_id'];
      onCallRoomID.value = resp['room']['roomName'];
      onCallRoomToken.value = resp['room']['token'];

      debugPrint("Room ID: ${onCallRoomID.value}");
      debugPrint("Room Token: ${onCallRoomToken.value}");
    });

    _audioPlayer.play(AssetSource('audio/talkliner-ringtone.mp3'));
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    outgoingCall.value = true;
  }

  void endCall() {
    _audioPlayer.stop();
    _audioPlayer.play(AssetSource('audio/disconnect.mp3'));
    _audioPlayer.setReleaseMode(ReleaseMode.release);

    // Tell the caller that the call has ended
    sendEvent('end', onCallWithUser.value.id, null, (response) {
      String message = "";

      message = response['message'] ?? "Failed to end call";

      onCallRoomID.value = '';
      onCallRoomToken.value = '';
      onCallID.value = '';
      callEnded.value = true;

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });

    callEnded.value = true;
  }

  void handleIncomingCall(Map<String, dynamic> resp) {
    
    if(resp['from'] == '') {
      return;
    }


    UserModel user = UserModel.fromJson(resp['from']);

    if(onCallID.value != '') {
      sendEvent('busy', user.id, null, (response){
        // Handle busy response
      });
      return;
    }

    incomingCall.value = true;
    showPopup(user);
  }
}
