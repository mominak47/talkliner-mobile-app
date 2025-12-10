import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/controllers/chat_controller.dart';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/services/notification_service.dart';
import 'package:talkliner/app/sql_tables/chat_table.dart';
import 'package:talkliner/app/sql_tables/messages_table.dart';

class ChatService {
  // Storage

  static Future<void> appendMessageToChat(
    String chatId,
    MessageModel message,
  ) async {
    debugPrint('Appending message to chat: $chatId, $message');

    var currentRoute = Get.currentRoute;
    HapticFeedback.heavyImpact();

    void showToast() {
      Fluttertoast.showToast(
        msg: "${message.displayName}: ${message.content}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
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
