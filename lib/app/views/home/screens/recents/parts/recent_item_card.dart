import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';

import 'package:intl/intl.dart';

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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(
      date.toLocal().year,
      date.toLocal().month,
      date.toLocal().day,
    );

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('d MMMM').format(date.toLocal());
    }
  }

  // Convert it into local time
  String _formatTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('h:mm a').format(date.toLocal());
  }

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
          if (recentItem.chatType == ChatType.individual &&
              recentItem.participants.isNotEmpty)
            UserAvatar(user: recentItem.participants[0].user),
          if (recentItem.chatType == ChatType.group)
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  isDarkMode
                      ? TalklinerThemeColors.gray030
                      : TalklinerThemeColors.gray900,
              child: Text(
                recentItem.name?.substring(0, 2) ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  recentItem.chatType == ChatType.individual &&
                          recentItem.participants.isNotEmpty
                      ? recentItem.participants[0].userId.displayName
                      : (recentItem.name ?? ''),
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? TalklinerThemeColors.gray030
                            : TalklinerThemeColors.gray900,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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
                        (recentItem.messages != null &&
                                recentItem.messages!.isNotEmpty)
                            ? recentItem.messages!.first.content
                            : '',
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
                (recentItem.messages != null && recentItem.messages!.isNotEmpty)
                    ? _formatDate(recentItem.messages!.first.timestamp)
                    : '',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isDarkMode
                          ? TalklinerThemeColors.gray050
                          : TalklinerThemeColors.gray300,
                ),
              ),
              Text(
                (recentItem.messages != null && recentItem.messages!.isNotEmpty)
                    ? _formatTime(recentItem.messages!.first.timestamp)
                    : '',
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
