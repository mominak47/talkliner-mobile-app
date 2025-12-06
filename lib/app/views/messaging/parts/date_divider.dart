import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class DateDivider extends StatelessWidget {
  final DateTime timestamp;

  const DateDivider({super.key, required this.timestamp});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? TalklinerThemeColors.gray800
                  : TalklinerThemeColors.gray040,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _formatDate(timestamp),
          style: TextStyle(
            color:
                isDarkMode
                    ? TalklinerThemeColors.gray300
                    : TalklinerThemeColors.gray200,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
