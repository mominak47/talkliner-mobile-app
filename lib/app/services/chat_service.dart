import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/controllers/chat_controller.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/sql_tables/chat_table.dart';
import 'package:talkliner/app/sql_tables/messages_table.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/messaging/chat.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';

class ChatService {
  // Storage

  static Future<void> appendMessageToChat(
    String chatId,
    MessageModel message,
  ) async {
    debugPrint('Appending message to chat: $chatId, $message');

    var currentRoute = Get.currentRoute;
    HapticFeedback.heavyImpact();

    // Get chat by chat ID
    ChatModel? chat = await ChatTable().getChatById(chatId);

    void showToast() {
      bool isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;

      String? user_name = null;

      if (chat != null) {
        user_name = chat.name;
      }

      Widget getProfilePic(ChatModel chat) {
        Widget profilePicture = SizedBox();
        bool isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;
        if (chat.chatType == ChatType.individual &&
            chat.participants.isNotEmpty) {
          profilePicture = UserAvatar(user: chat.participants[0].user!);
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
        user_name ?? "New Message",
        message.content,
        snackPosition: SnackPosition.TOP,
        backgroundColor:
            isDarkMode ? Colors.black : TalklinerThemeColors.gray020,
        colorText: isDarkMode ? Colors.white : Colors.black,
        icon: getProfilePic(chat!),
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

    if (currentRoute == '/Chat') {
      final chatController = Get.find<ChatController>();

      if (chatController.getCurrentChat()?.id != chatId) {
        showToast();
      }
    } else {
      showToast();
    }

    MessagesTable().insert(message, chatId);
  }
}
