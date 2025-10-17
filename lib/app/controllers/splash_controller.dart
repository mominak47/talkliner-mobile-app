import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/config/routes.dart';
import 'package:talkliner/app/config/app_config.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/controllers/home_controller.dart';
import 'package:talkliner/app/controllers/push_to_talk_controller.dart';
import 'package:talkliner/app/views/home/home_view.dart';

class SplashController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final PushToTalkController pushToTalkController =
      Get.find<PushToTalkController>();
  final HomeController homeController = Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: AppConfig.splashDelay), () {
      try {
        if (authController.isLoggedIn.value) {
          homeController.setCurrentIndex(2);
          Get.offAll(
            () => HomeView(),
            transition: Transition.fadeIn,
            duration: Duration.zero,
          );
          debugPrint("User logged in");
        } else {
          Get.offAllNamed(Routes.login);
          debugPrint("User not logged in");
        }
      } catch (e) {
        debugPrint('[SplashController] Navigation error: $e');
        // Fallback to login screen if there's an error
        Get.offAllNamed(Routes.login);
      }
    });
  }
}
