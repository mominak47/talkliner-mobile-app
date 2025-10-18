import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

// Replace 'User' with your actual user model class
class GroupCard extends StatelessWidget {
  final dynamic group; // Use your actual UserModel type here
  final IconData onTapIcon;
  final Color onTapIconColor;
  final VoidCallback onTap;
  final VoidCallback onTapCard;
  final bool isSelected;

  const GroupCard({
    super.key,
    required this.group,
    required this.onTapIcon,
    required this.onTapIconColor,
    required this.onTap,
    required this.onTapCard,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Replace with your actual theme and avatar logic as needed
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton(
      onPressed: onTapCard,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: TalklinerThemeColors.primary500,
        foregroundColor: theme.primaryColor,
        overlayColor: TalklinerThemeColors.primary500,
        elevation: 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Replace with your actual UserAvatar widget
          CircleAvatar(
              backgroundColor: isDarkMode ? TalklinerThemeColors.gray700 : TalklinerThemeColors.gray080,
              radius: 25,
            child: Icon(LucideIcons.users, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  group.name,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      isSelected ? LucideIcons.volume2 : LucideIcons.volumeX,
                      size: 16,
                      color: isSelected ? theme.primaryColor : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${group.memberCount.toString()} users',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(
              onTapIcon,
              color:
                  isSelected
                      ? (isDarkMode ? Colors.black : Colors.white)
                      : TalklinerThemeColors.gray080,
            ),
            style: IconButton.styleFrom(
              backgroundColor:
                  isSelected
                      ? TalklinerThemeColors.primary500
                      : (isDarkMode
                          ? TalklinerThemeColors.gray800
                          : TalklinerThemeColors.gray040),
            ),
          ),
        ],
      ),
    );
  }
}
