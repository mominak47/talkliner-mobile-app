import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/models/message_model.dart';

class ChatService {
  // Storage

  static Future<void> appendMessageToChat(
    String chatId,
    MessageModel message,
  ) async {
    final GetStorage storage = GetStorage();
    debugPrint('Appending message to chat: $chatId, $message');
    var storageKey = 'chat_$chatId';

    var chat = storage.read(storageKey);
    if (chat != null) {
      // Check if message already exists
      if (!chat.messages.any((m) => m.id == message.id)) {
        chat.messages.add(message);
        storage.write(storageKey, chat);
      }
    }
  }
}
