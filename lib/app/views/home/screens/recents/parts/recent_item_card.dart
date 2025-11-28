import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';

class RecentItemCard extends StatelessWidget {
  const RecentItemCard({
    super.key,
    required this.recentItem,
    required this.onTapIconColor,
    required this.onTap,
    required this.isSelected,
  });
  final ChatModel recentItem;
  final Color onTapIconColor;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final authController = Get.find<AuthController>();

    final user = authController.user.value;

    final bool isMyMessage = recentItem.lastMessage?.senderId.id == user?.id;

    return ElevatedButton(
      onPressed: onTap,
      onLongPress: () {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Delete'),
                content: Text(
                  'Are you sure you want to delete this recent item?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Delete'),
                  ),
                ],
              ),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: TalklinerThemeColors.primary500,
        foregroundColor: theme.primaryColor,
        elevation: 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserAvatar(user: recentItem.participants[0].user),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  recentItem.participants[0].userId.displayName,
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? TalklinerThemeColors.gray030
                            : TalklinerThemeColors.gray900,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      LucideIcons.messageSquare,
                      size: 16,
                      color: TalklinerThemeColors.gray500,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isMyMessage
                          ? LucideIcons.arrowDownRight
                          : LucideIcons.arrowUpRight,
                      size: 16,
                      color:
                          isMyMessage
                              ? TalklinerThemeColors.green500
                              : TalklinerThemeColors.primary500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        recentItem.lastMessage?.content ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDarkMode
                                  ? TalklinerThemeColors.gray050
                                  : TalklinerThemeColors.gray500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '01.01.2025',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isDarkMode
                          ? TalklinerThemeColors.gray050
                          : TalklinerThemeColors.gray300,
                ),
              ),
              Text(
                '04:32pm',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isDarkMode
                          ? TalklinerThemeColors.gray050
                          : TalklinerThemeColors.gray300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
