import 'package:flutter/material.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class SettingsSectionContainer extends StatelessWidget {
  const SettingsSectionContainer({
    super.key,
    required this.title,
    required this.children,
    this.border = true,
  });
  final String title;
  final List<Widget> children;
  final bool border;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: border ? Border.all(color: isDarkMode ? TalklinerThemeColors.gray800 : TalklinerThemeColors.gray030) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != "")
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? TalklinerThemeColors.gray100 : TalklinerThemeColors.gray800,
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}
