import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/controllers/livekit_room_controller.dart';
import 'package:talkliner/app/models/group_model.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/services/api_service.dart';
import 'package:talkliner/app/views/home/screens/pushtotalk/widgets/push_to_talk_button.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class PushToTalkController extends GetxController {
  // Selected User
  final Rx<UserModel> selectedUser = UserModel.fromJson({}).obs;
  // Selected Group
  final Rx<GroupModel> selectedGroup = GroupModel.fromJson({}).obs;

  final LivekitRoomController livekitRoomController =
      Get.put<LivekitRoomController>(LivekitRoomController());
  final RxBool isPTTActive = false.obs;
  final ApiService apiService = ApiService();

  // Timer
  Timer? _timer;
  Worker? _selectedUserWorker, _selectedGroupWorker;

  // Audios
  final _audioPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    apiService.onInit();

    _selectedUserWorker = ever(selectedUser, (user) {
      livekitRoomController.isRoomConnecting.value = true;
      livekitRoomController.connectToUserRoom(user);
    });

    _selectedGroupWorker = ever(selectedGroup, (group) {
      livekitRoomController.isRoomConnecting.value = true;
      livekitRoomController.connectToGroupRoom(group);
    });

    // Fallback to reconncet to room if user is selected
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _reconnectToRoom();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    _selectedUserWorker?.dispose();
    _selectedGroupWorker?.dispose();
    _audioPlayer.dispose();
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
    _audioPlayer.stop();
    _audioPlayer.play(AssetSource('audio/disconnect.mp3'));
    _audioPlayer.setReleaseMode(ReleaseMode.release);
    livekitRoomController.disconnectFromRoom();
    selectedUser.value = UserModel.fromJson({});
    selectedGroup.value = GroupModel.fromJson({});
  }

  void setUser(UserModel user) {
    // Unset Selected Group
    if (selectedGroup.value.id.isNotEmpty) {
      removeUser();
    }
    selectedUser.value = user;
  }

  void setGroup(GroupModel group) {
    // Unset Selected User
    if (selectedUser.value.id.isNotEmpty) {
      removeUser();
    }
    selectedGroup.value = group;
  }

  void startPTT() async {
    try {
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
    } catch (e) {
      debugPrint("Error starting PTT: $e");
    }
  }

  void stopPTT() async {
    try {
      isPTTActive.value = false;
      livekitRoomController.stopSpeaking();
      if (getPTTButtonState() != PushToTalkButtonState.notSelected) {
        playAudio('audio/disconnect.mp3', volume: 1.0);
      }
      debugPrint('PTT stopped successfully');
    } catch (e) {
      debugPrint("Error stopping PTT: $e");
    }
  }

  PushToTalkButtonState getPTTButtonState() {
    if (selectedUser.value.id.isEmpty && selectedGroup.value.id.isEmpty) {
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
    if (selectedUser.value.id.isEmpty && selectedGroup.value.id.isEmpty) {
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
    if (selectedUser.value.id.isNotEmpty) {
      livekitRoomController.connectToUserRoom(selectedUser.value);
    } else if (selectedGroup.value.id.isNotEmpty) {
      livekitRoomController.connectToGroupRoom(selectedGroup.value);
    }
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
