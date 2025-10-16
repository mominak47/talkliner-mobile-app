import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/controllers/splash_controller.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    return Scaffold(
      body: Center(
        child: Get.isDarkMode ? 
        SvgPicture.asset('assets/logos/white_logo.svg', height: 50) : 
        SvgPicture.asset('assets/logos/talkliner.svg', height: 50),
      ),
    );
  }
}
