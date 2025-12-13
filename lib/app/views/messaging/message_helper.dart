import 'dart:ui';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class MessageHelper {
  static Color getMessageTextColor(MessageModel message, bool isDarkMode) {
    if (message.id == "sending") {
      return TalklinerThemeColors.primary100;
    }
    return message.isMe
        ? (isDarkMode
            ? TalklinerThemeColors.primary800
            : TalklinerThemeColors.primary700)
        : (isDarkMode
            ? TalklinerThemeColors.gray050
            : TalklinerThemeColors.gray700);
  }

  static Color getMessageColor(MessageModel message, bool isDarkMode) {
    if (message.id == "sending") {
      return TalklinerThemeColors.primary025;
    }
    return message.isMe
        ? (isDarkMode
            ? TalklinerThemeColors.primary100
            : TalklinerThemeColors.primary050)
        : (isDarkMode
            ? TalklinerThemeColors.gray700
            : TalklinerThemeColors.gray040);
  }
}
