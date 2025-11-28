import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';

// Replace 'User' with your actual user model class
class ContactCard extends StatelessWidget {
  final dynamic user; // Use your actual UserModel type here
  final IconData onTapIcon;
  final Color onTapIconColor;
  final VoidCallback onTap;
  final VoidCallback onTapCard;
  final bool isSelected;
  final VoidCallback onLongPress;
  const ContactCard({
    super.key,
    required this.user,
    required this.onTapIcon,
    required this.onTapIconColor,
    required this.onTap,
    required this.onTapCard,
    required this.isSelected,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // final livekitRoomController = Get.find<LivekitRoomController>();

    // Replace with your actual theme and avatar logic as needed
    final theme = Theme.of(context);

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      onPressed: onTapCard,
      onLongPress: onLongPress,
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
          UserAvatar(user: user),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? LucideIcons.volume2 : LucideIcons.volumeX,
                      size: 16,
                      color:
                          isSelected
                              ? (isDarkMode
                                  ? TalklinerThemeColors.gray200
                                  : Colors.black)
                              : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.status.substring(0, 1).toUpperCase() +
                          user.status.substring(1),
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDarkMode
                                ? TalklinerThemeColors.gray200
                                : Colors.grey,
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
