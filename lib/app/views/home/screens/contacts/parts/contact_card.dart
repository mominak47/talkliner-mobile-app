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

  const ContactCard({
    super.key,
    required this.user,
    required this.onTapIcon,
    required this.onTapIconColor,
    required this.onTap,
    required this.onTapCard,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    // final livekitRoomController = Get.find<LivekitRoomController>();

    // Replace with your actual theme and avatar logic as needed
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return ElevatedButton(
      onPressed: onTapCard,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: theme.primaryColor,
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
                    color: isLight ? Colors.black87 : Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
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
                      user.status.substring(0, 1).toUpperCase() +
                          user.status.substring(1),
                      style: TextStyle(
                        fontSize: 14,
                        color: isLight ? Colors.grey : Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon( onTapIcon, color: isSelected ? Colors.white : TalklinerThemeColors.gray080),
            style: IconButton.styleFrom(backgroundColor: isSelected ? TalklinerThemeColors.primary500 : TalklinerThemeColors.gray040),
          ),
        ],
      ),
    );
  }
}
