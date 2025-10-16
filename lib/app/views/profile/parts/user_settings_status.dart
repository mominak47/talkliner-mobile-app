import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/profile/parts/settings_section_container.dart';
import 'package:talkliner/app/views/utils/checkbox_item.dart';

enum UserStatus {
  online,
  busy,
  solo,
  offline,
}

class UserSettingsStatus extends StatelessWidget {
  const UserSettingsStatus({super.key});

  @override
  Widget build(BuildContext context) {

    return SettingsSectionContainer(
      title: 'Status',
      children: [
        CheckboxItem(
          icon: LucideIcons.check,
          iconBackground: TalklinerThemeColors.green500,
          iconColor: Colors.white,
          title: 'Online',
          value: true,
          onChanged: (value) {},
        ),
        CheckboxItem(
          icon: LucideIcons.clock,
          iconBackground: TalklinerThemeColors.primary500,
          iconColor: Colors.white,
          title: 'Busy',
          value: true,
          onChanged: (value) {},
        ),
        CheckboxItem(
          icon: LucideIcons.personStanding,
          iconBackground: TalklinerThemeColors.blue500,
          iconColor: Colors.white,
          title: 'Solo',
          value: true,
          onChanged: (value) {},
        ),
        CheckboxItem(
          icon: LucideIcons.x,
          iconBackground: TalklinerThemeColors.gray080,
          iconColor: Colors.white,
          title: 'Offline',
          value: true,
          onChanged: (value) {},
        ),
      ],
    );
  }
}