import 'package:flutter/material.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class TabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  const TabButton({super.key, required this.title, required this.icon, required this.onTap, required this.isSelected});

  @override
  Widget build(BuildContext context) {

    // Is light mode
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: isSelected ? TalklinerThemeColors.primary500 :
      isLightMode ? TalklinerThemeColors.gray020 : TalklinerThemeColors.gray700,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      overlayColor: TalklinerThemeColors.primary500,
    ), child: Row(
      children: [
        Icon(icon, size: 16, color: isSelected ? TalklinerThemeColors.gray700 : isLightMode ? TalklinerThemeColors.gray800 : TalklinerThemeColors.gray020),
        SizedBox(width: 4),
        Text(title, style: TextStyle(
          color: isSelected ? TalklinerThemeColors.gray700 : isLightMode ? TalklinerThemeColors.gray800 : TalklinerThemeColors.gray020, 
          fontSize: 14, 
          fontWeight: FontWeight.bold
        ))
      ],
    ));
  }
}