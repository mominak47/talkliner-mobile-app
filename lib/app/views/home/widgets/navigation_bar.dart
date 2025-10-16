import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/home_controller.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Obx(() => BottomNavigationBar(
      currentIndex: homeController.currentIndex.value,
      onTap: (index) => homeController.setCurrentIndex(index),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedItemColor: TalklinerThemeColors.primary500,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: Colors.transparent,
      items: [
        BottomNavigationBarItem(icon: Icon(LucideIcons.history), label: ''),
        BottomNavigationBarItem(icon: Icon(LucideIcons.contact), label: ''),
        BottomNavigationBarItem(icon: Icon(LucideIcons.mic), label: ''),
        BottomNavigationBarItem(icon: Icon(LucideIcons.mapPin), label: ''),
        BottomNavigationBarItem(icon: Icon(LucideIcons.newspaper), label: ''),
      ],
    ));
  }
}