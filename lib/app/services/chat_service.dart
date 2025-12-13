import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/controllers/chat_controller.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/sql_tables/chat_table.dart';
import 'package:talkliner/app/sql_tables/messages_table.dart';
import 'package:talkliner/app/utils/notification_helper.dart';

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
      NotificationHelper.showNewMessageNotification(
        chat: chat,
        message: message,
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
