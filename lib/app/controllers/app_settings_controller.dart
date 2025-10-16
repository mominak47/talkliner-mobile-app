import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
class AppSettingsController extends GetxController {
  AuthController authController = Get.find<AuthController>();

  final RxBool isDarkMode = false.obs;
  final RxString language = 'en'.obs;
  final RxBool showFloatingPushToTalkButton = true.obs;
  final RxBool vibrateOnIncomingPTT = true.obs;
  final RxBool whenBluetoothDisconnects = false.obs;
  final RxBool pttDuringCellular = false.obs;
  final RxBool rejectPhoneCalls = false.obs;
  final RxBool incomingPTTAlert = false.obs;
  final RxBool outgoingPTTAlert = false.obs;
  final RxBool pttEarphonesControl = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load settings from storage
    listenToSettingsChanges();
    authController.isLoggedIn.listen((isLoggedIn) => isLoggedIn ? loadSettings() : clearSettings());
  }

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
  }

  void changeLanguage(String language) {
    this.language.value = language;
  }

  void setShowFloatingPushToTalkButton(bool value) => showFloatingPushToTalkButton.value = value;
  void setVibrateOnIncomingPTT(bool value) => vibrateOnIncomingPTT.value = value;
  void setWhenBluetoothDisconnects(bool value) => whenBluetoothDisconnects.value = value;
  void setPttDuringCellular(bool value) => pttDuringCellular.value = value;
  void setRejectPhoneCalls(bool value) => rejectPhoneCalls.value = value;
  void setIncomingPTTAlert(bool value) => incomingPTTAlert.value = value;
  void setOutgoingPTTAlert(bool value) => outgoingPTTAlert.value = value;
  void setPttEarphonesControl(bool value) => pttEarphonesControl.value = value;

  // Load settings
  void loadSettings() {
    showFloatingPushToTalkButton.value = GetStorage().read('settings.showFloatingPushToTalkButton') ?? true;
    vibrateOnIncomingPTT.value = GetStorage().read('settings.vibrateOnIncomingPTT') ?? true;
    whenBluetoothDisconnects.value = GetStorage().read('settings.whenBluetoothDisconnects') ?? false;
    pttDuringCellular.value = GetStorage().read('settings.pttDuringCellular') ?? false;
    rejectPhoneCalls.value = GetStorage().read('settings.rejectPhoneCalls') ?? false;
    incomingPTTAlert.value = GetStorage().read('settings.incomingPTTAlert') ?? false;
    outgoingPTTAlert.value = GetStorage().read('settings.outgoingPTTAlert') ?? false;
    pttEarphonesControl.value = GetStorage().read('settings.pttEarphonesControl') ?? false;
  }

  // Listen to settings changes
  void listenToSettingsChanges() {
    showFloatingPushToTalkButton.listen((value) => GetStorage().write('settings.showFloatingPushToTalkButton', value));
    vibrateOnIncomingPTT.listen((value) => GetStorage().write('settings.vibrateOnIncomingPTT', value));
    whenBluetoothDisconnects.listen((value) => GetStorage().write('settings.whenBluetoothDisconnects', value));
    pttDuringCellular.listen((value) => GetStorage().write('settings.pttDuringCellular', value));
    rejectPhoneCalls.listen((value) => GetStorage().write('settings.rejectPhoneCalls', value));
    incomingPTTAlert.listen((value) => GetStorage().write('settings.incomingPTTAlert', value));
    outgoingPTTAlert.listen((value) => GetStorage().write('settings.outgoingPTTAlert', value));
    pttEarphonesControl.listen((value) => GetStorage().write('settings.pttEarphonesControl', value));
  }

  // Clear settings
  void clearSettings() {
    GetStorage().remove('settings.showFloatingPushToTalkButton');
    GetStorage().remove('settings.vibrateOnIncomingPTT');
    GetStorage().remove('settings.whenBluetoothDisconnects');
    GetStorage().remove('settings.pttDuringCellular');
    GetStorage().remove('settings.rejectPhoneCalls');
    GetStorage().remove('settings.incomingPTTAlert');
    GetStorage().remove('settings.outgoingPTTAlert');
    GetStorage().remove('settings.pttEarphonesControl');
  }
}