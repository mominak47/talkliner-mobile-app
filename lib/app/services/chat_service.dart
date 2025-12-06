import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/sql_tables/chat_table.dart';
import 'package:talkliner/app/sql_tables/messages_table.dart';

class ChatService {
  // Storage

  static Future<void> appendMessageToChat(
    String chatId,
    MessageModel message,
  ) async {
    debugPrint('Appending message to chat: $chatId, $message');

    MessagesTable().insert(message, chatId);
  }
}
