import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/models/message_model.dart';

class ChatCache {
  final GetStorage getStorage = GetStorage("chat_cache");
  final String key = "chat_cache_";

  saveChat(ChatModel chat) {
    getStorage.write(key + chat.id, chat.toJson());
    print("Chat saved to cache: ${chat.id}");
  }

  ChatModel? getChat(String chatId) {
    var chat = getStorage.read(key + chatId);
    if (chat != null) {
      return ChatModel.fromJson(chat);
    }
    return null;
  }

  deleteChat(String chatId) {
    getStorage.remove(key + chatId);
  }

  addMessages(String chatId, List<MessageModel> messages) {
    var chat = getChat(chatId);
    if (chat != null) {
      var newMessages = <MessageModel>[];
      if (chat.messages != null) {
        newMessages.addAll(chat.messages!);
      }
      newMessages.addAll(messages);
      chat = chat.copyWith(messages: newMessages);
      saveChat(chat);
    }
  }
}
