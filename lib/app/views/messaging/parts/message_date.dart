import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class MessageDate extends StatelessWidget {
  final DateTime timestamp;
  const MessageDate({super.key, required this.timestamp});

  @override
  Widget build(BuildContext context) {

    final localTimestamp = timestamp.toLocal();
    final formattedTime = DateFormat('h:mm a').format(localTimestamp);
    // Convert timestamp to local timezone
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Text(
      formattedTime,
      style: TextStyle(color: isDarkMode ? TalklinerThemeColors.gray050 : TalklinerThemeColors.gray500, fontSize: 12),
    );
  }
}
