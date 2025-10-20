import 'package:get/get.dart';
import 'package:talkliner/app/controllers/app_settings_controller.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/controllers/call_controller.dart';
import 'package:talkliner/app/controllers/contacts_controller.dart';
import 'package:talkliner/app/controllers/home_controller.dart';
import 'package:talkliner/app/controllers/layout_controller.dart';
import 'package:talkliner/app/controllers/map_controller.dart';
import 'package:talkliner/app/controllers/push_to_talk_controller.dart';
import 'package:talkliner/app/controllers/recents_controller.dart';
import 'package:talkliner/app/controllers/socket_controller.dart';
import 'package:talkliner/app/services/auth_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {

    // Lazily put the AuthService, so it's created only when first needed.
    Get.put<LayoutController>(LayoutController());
    Get.put<AuthService>(AuthService());
    Get.put<AuthController>(AuthController());
    Get.put<AppSettingsController>(AppSettingsController());
    Get.put<HomeController>(HomeController());
    Get.put<SocketController>(SocketController());
    Get.put<PushToTalkController>(PushToTalkController());
    Get.put<MapController>(MapController());
    Get.put<CallController>(CallController());

    Get.put<ContactsController>(ContactsController());

    Get.put<RecentsController>(RecentsController());
  }
}