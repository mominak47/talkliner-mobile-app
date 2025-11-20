import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/cachemanagers/token_manager.dart';
import 'package:talkliner/app/config/routes.dart';
import 'package:talkliner/app/config/app_config.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/controllers/home_controller.dart';
import 'package:talkliner/app/views/home/home_view.dart';

class SplashController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final HomeController homeController = Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: AppConfig.splashDelay), () async {
      try {
        TokenModel token = await TokenManager.getToken();
        if (token.isValid) {
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
