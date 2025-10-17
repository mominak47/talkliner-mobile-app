import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class RadioItem extends StatelessWidget {
  final IconData? icon;
  final String? svgIconPath;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? description;

  const RadioItem({
    super.key,
    this.icon,
    this.svgIconPath,
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      onPressed: () => onChanged(!value),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        overlayColor: TalklinerThemeColors.primary500,
      ),
      child: Row(
        children: [
          svgIconPath != null
              ? SvgPicture.asset(svgIconPath!, width: 24, height: 24)
              : Icon(icon, color: isDarkMode ? TalklinerThemeColors.gray050 : TalklinerThemeColors.gray800),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? TalklinerThemeColors.gray050 : TalklinerThemeColors.gray800,
                  ),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? TalklinerThemeColors.gray400 : TalklinerThemeColors.gray500,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
            child: Switch(
              value: value,
              onChanged: onChanged,
              // Use thumbIcon instead of ImageProvider to avoid SVG as bitmap
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                final bool isSelected = states.contains(WidgetState.selected);
                return Icon(
                  isSelected ? LucideIcons.check : LucideIcons.x,
                  size: 18,
                  weight: 600,
                  shadows: [],
                  color:
                      isSelected
                          ? TalklinerThemeColors.primary500
                          : isDarkMode ? TalklinerThemeColors.gray800 : TalklinerThemeColors.gray050,
                );
              }),
              thumbColor: WidgetStateProperty.resolveWith<Color?>(
                (states) => Colors.white,
              ),
              // Optionally customize colors
              trackColor: WidgetStateProperty.resolveWith<Color?>(
                (states) =>
                    states.contains(WidgetState.selected)
                        ? TalklinerThemeColors.primary500
                        : isDarkMode ? TalklinerThemeColors.gray800 : TalklinerThemeColors.gray050,
              ),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}
