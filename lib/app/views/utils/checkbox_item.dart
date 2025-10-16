import 'package:flutter/material.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class CheckboxItem extends StatelessWidget {
  const CheckboxItem({super.key, required this.title, required this.value, required this.onChanged, required this.icon, required this.iconColor, required this.iconBackground});
  final String title;
  final bool value;
  final Function(bool?) onChanged;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: iconBackground,
              child: Icon(icon, size: 16, color: iconColor),
            ),
            SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 16,color: isDarkMode ? TalklinerThemeColors.gray100 : TalklinerThemeColors.gray800, fontWeight: FontWeight.w500),),
          ],
        ),
        Checkbox(
          value: false,
          onChanged: onChanged,
          activeColor: TalklinerThemeColors.primary500,
          checkColor: Colors.white,
          side: BorderSide(color: isDarkMode ? TalklinerThemeColors.gray800 : TalklinerThemeColors.gray040, width: 2),
        ),
      ],
    );
  }
}