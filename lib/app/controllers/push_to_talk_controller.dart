import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/controllers/livekit_room_controller.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/services/api_service.dart';
import 'package:talkliner/app/views/home/screens/pushtotalk/widgets/push_to_talk_button.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class PushToTalkController extends GetxController {
  // Selected User
  final Rx<UserModel> selectedUser = UserModel.fromJson({}).obs;
  final LivekitRoomController livekitRoomController =
      Get.put<LivekitRoomController>(LivekitRoomController());
  final RxBool isPTTActive = false.obs;
  final ApiService apiService = ApiService();

  // Timer
  Timer? _timer;

  // Audios
  final _audioPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    apiService.onInit();
    
    selectedUser.listen((user) {
      livekitRoomController.connectToRoom(user);
    });

    // Fallback to reconncet to room if user is selected
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _reconnectToRoom();
    });

    // Fallback to get user from local storage
    // try {
    //   final user = getUserFromLocalStorage();
    //   debugPrint('[PushToTalkController] User from local storage: ${user}');
    //   if (user.id.isNotEmpty) {
    //     selectedUser.value = user;
    //     livekitRoomController.connectToRoom(user);
    //   }
    // } catch (e) {
    //   debugPrint('[PushToTalkController] Error getting user from local storage: $e');
    // }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }


  void playAudio(String audioPath, {double volume = 1.0}) {
    try {
      if (_audioPlayer.state == PlayerState.playing) {
        _audioPlayer.stop();
      }
      // Set volume to full
      _audioPlayer.setVolume(volume);
      _audioPlayer.play(AssetSource(audioPath));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  void removeUser() {
    livekitRoomController.disconnectFromRoom();
    selectedUser.value = UserModel.fromJson({});
  }

  void setUser(UserModel user) {
    saveUserToLocalStorage(user);
    selectedUser.value = user;
  }

  void startPTT() async {
    if (getPTTButtonState() == PushToTalkButtonState.notSelected) {
      // Give a toast message that no user is selected
      Get.snackbar(
        'No User Selected',
        'Please select a user to start PTT',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isPTTActive.value = true;
    playAudio('audio/connect.mp3', volume: 1.0);
    livekitRoomController.speak();
    debugPrint('PTT started successfully');
  }

  void stopPTT() async {
    isPTTActive.value = false;
    livekitRoomController.stopSpeaking();
    if (getPTTButtonState() != PushToTalkButtonState.notSelected) {
      playAudio('audio/disconnect.mp3', volume: 1.0);
    }
    debugPrint('PTT stopped successfully');
  }

  PushToTalkButtonState getPTTButtonState() {
    if (selectedUser.value.id.isEmpty) {
      return PushToTalkButtonState.notSelected;
    }
    if (livekitRoomController.isRoomConnecting.value) {
      return PushToTalkButtonState.connectingRoom;
    }

    return isPTTActive.value
        ? PushToTalkButtonState.active
        : PushToTalkButtonState.inactive;
  }

  void _reconnectToRoom() {
    // Check if user is selected
    if (selectedUser.value.id.isEmpty) {
      return;
    }

    // Check if room is connected
    if (livekitRoomController.isRoomConnecting.value) {
      return;
    }

    // Check if room is connected
    if (livekitRoomController.isConnected.value) {
      return;
    }

    // Reconnect to room
    livekitRoomController.connectToRoom(selectedUser.value);
  }

  // Save the user to local storage
  void saveUserToLocalStorage(UserModel user) {
    debugPrint(
      '[PushToTalkController] Saving user to local storage: ${user.toJson()}',
    );
    GetStorage().write('ptt_selectedUser', user.toJson());
  }

  // Get the user from local storage
  UserModel getUserFromLocalStorage() {
    final user =
        GetStorage().read('ptt_selectedUser') ?? UserModel.fromJson({});
    return UserModel.fromJson(user);
  }
}
