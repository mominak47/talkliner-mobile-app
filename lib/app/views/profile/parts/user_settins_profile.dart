import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';
import 'package:talkliner/app/views/profile/parts/settings_section_container.dart';

class UserSettingsProfile extends StatelessWidget {
  const UserSettingsProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SettingsSectionContainer(
      title: '',
      border: false,
      children: [
        Center(
          child: Column(
            children: [
              UserAvatar(user: authController.user.value, size: 100),
              Text(authController.user.value?.displayName ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? TalklinerThemeColors.gray100 : TalklinerThemeColors.gray800),),
              Text('@${authController.user.value?.username ?? ''}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: isDarkMode ? TalklinerThemeColors.gray400 : TalklinerThemeColors.gray500),),
            ],
          ),
        ),
      ],
    );
  }
}
