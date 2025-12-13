import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/messaging/chat.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';

class NotificationHelper {
  static void showNewMessageNotification({
    required ChatModel? chat,
    required MessageModel message,
  }) {
    // Safety check for context
    if (Get.context == null) return;

    bool isDarkMode = Get.isDarkMode;

    String? userName;

    if (chat != null) {
      userName = chat.name;
    }

    Widget getProfilePic(ChatModel chat) {
      Widget profilePicture = const SizedBox();
      // Re-fetch theme brightness inside the widget build if needed,
      // but here we are in a static helper, using the one captured above is fine for this sync execution.
      // However, Get.snackbar builds a widget so it uses current context.

      bool isDarkMode = Get.isDarkMode;

      if (chat.chatType == ChatType.individual &&
          chat.participants.isNotEmpty) {
        if (chat.participants[0].user != null) {
          profilePicture = UserAvatar(user: chat.participants[0].user!);
        }
      }

      if (chat.chatType == ChatType.group) {
        profilePicture = CircleAvatar(
          radius: 24,
          backgroundColor:
              isDarkMode
                  ? TalklinerThemeColors.gray900
                  : TalklinerThemeColors.gray020,
          child: Icon(Icons.group, color: TalklinerThemeColors.gray050),
        );
      }

      return profilePicture;
    }

    Get.snackbar(
      userName ?? "New Message",
      message.content,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isDarkMode ? Colors.black : TalklinerThemeColors.gray020,
      colorText: isDarkMode ? Colors.white : Colors.black,
      icon: chat != null ? getProfilePic(chat) : const SizedBox(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      duration: const Duration(seconds: 3),
      onTap: (snackbar) {
        if (chat != null) {
          // Hide snackbar
          Get.closeCurrentSnackbar();
          Get.to(() => Chat(chat: chat));
        }
      },
    );
  }
}
