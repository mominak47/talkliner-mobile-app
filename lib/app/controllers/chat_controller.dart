import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/controllers/recents_controller.dart';
import 'package:talkliner/app/controllers/socket_controller.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/services/api_service.dart';
import 'package:talkliner/app/sql_tables/messages_table.dart';
import 'package:talkliner/app/helpers/database_helper.dart';

class ChatController extends GetxController {
  final ChatModel chat;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final ApiService apiService = ApiService();
  final isKeyboardVisible = false.obs;
  final isTyping = false.obs;

  // Pagination
  int currentPage = 1;
  final isLoadingMore = false.obs;
  bool hasMoreMessages = true;
  final int perPage = 50;

  final _audioPlayer = AudioPlayer();

  final RecentsController recentsController = Get.find<RecentsController>();

  ChatController({required this.chat});
  final SocketController socketController = Get.find<SocketController>();
  final AuthController authController = Get.find<AuthController>();

  void watchSocketEvent() {}

  @override
  void onInit() {
    super.onInit();

    apiService.onInit();
    getMessagesFromStorage();
    // fetchMessages();
    // recentsController.fetchRecents();
    watchSocketEvent();

    // Listen to database changes
    DatabaseHelper().onDatabaseChanged.listen((table) {
      if (['messages'].contains(table)) {
        getMessagesFromStorage();
      }
    });

    ever(
      messages,
      (_) => {
        // If messages is not empty, save to local storage
        // if (messages.isNotEmpty) {saveInfoInLocalStorage()},
      },
    );
  }

  void emitUserTyping(bool state) {
    try {
      // socketController.emitTo(user, 'user_typing', {
      //   'state': state,
      //   'from': authController.user.value!.id,
      // });
    } catch (e) {
      debugPrint("Error emitting user typing: $e");
    }
  }

  @override
  void onClose() {
    super.onClose();
    messages.clear();
    recentsController.fetchRecents();
  }

  Future<void> fetchMessages({int page = 1}) async {
    if (page == 1) {
      currentPage = 1;
      hasMoreMessages = true;
    }

    try {
      final messagesResponse = await chat.getMessages(
        perPage: perPage,
        page: page,
      );

      for (var message in messagesResponse) {
        await MessagesTable().insert(message, chat.id);
      }

      getMessagesFromStorage();
    } catch (e) {
      debugPrint("[TALKLINER SERVICE] Error fetched messages: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreMessages() async {
    if (isLoadingMore.value || !hasMoreMessages) return;

    isLoadingMore.value = true;
    currentPage++;
    debugPrint("Loading more messages: page $currentPage");
    await fetchMessages(page: currentPage);
  }

  Future<void> sendMessage(String content) async {
    try {
      // Add the message to the messages list
      messages.add(
        MessageModel(
          id: "sending",
          senderId: authController.user.value!.id,
          content: content,
          messageType: 'text',
          timestamp: DateTime.now(),
          edited: false,
          isMe: true,
        ),
      );

      final response = await chat.sendMessage(content);
      final jsonBody = jsonDecode(response.body);

      debugPrint("[Chat Controller] sendMessage: ${jsonBody.toString()}");
      // Play a sound
      _audioPlayer.play(AssetSource('audio/message-sent.mp3'));
      _audioPlayer.setReleaseMode(ReleaseMode.release);

      // Delete the message by id
      messages.removeWhere((message) => message.id == "sending");

      messages.add(MessageModel.fromJson(jsonBody['data']['message']));

      // Add message to database
      await MessagesTable().insert(messages.last, chat.id);

      debugPrint(
        "[Chat Controller] added message: ${messages.last.toString()}",
      );
    } catch (e) {
      debugPrint("[Chat Controller] Error sending message: $e");
    }
  }

  getMessagesFromStorage() async {
    try {
      final messagesResponse = await MessagesTable().getMessages(chat.id, 50);

      messages.clear();
      for (var message in messagesResponse) {
        messages.add(MessageModel.fromJson(message));
      }
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // debugPrint(
      //   "[Chat Controller] getMessagesFromStorage: ${messagesResponse[0].toString()}",
      // );
    } catch (e) {
      debugPrint("[Chat Controller] Error fetching messages: $e");
    }
  }
}
