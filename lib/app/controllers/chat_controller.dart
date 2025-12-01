import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/controllers/recents_controller.dart';
import 'package:talkliner/app/controllers/socket_controller.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/services/api_service.dart';

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

  // Storage
  final GetStorage _storage = GetStorage();

  final RecentsController recentsController = Get.find<RecentsController>();

  ChatController({required this.chat});
  final SocketController socketController = Get.find<SocketController>();
  final AuthController authController = Get.find<AuthController>();

  void watchSocketEvent() {
    // socketController.event.listen((event) {
    //   if (event == 'new_message') {
    //     try {
    //       final eventData = socketController.eventData;
    //       if (eventData['message'] != null &&
    //           eventData['message']['sender_id']['_id'] !=
    //               authController.user.value?.id) {
    //         final message = MessageModel.fromJson(eventData['message']);
    //         // Check if message already exists to avoid duplicates
    //         if (!messages.any((m) => m.id == message.id)) {
    //           messages.add(message);
    //           // Save to local storage
    //           // saveInfoInLocalStorage();
    //         }
    //       }
    //     } catch (e) {
    //       debugPrint('ChatController: Error parsing message: $e');
    //     }
    //   }

    //   if (event == 'USER_TO_USER_EVENT') {
    //     final eventData = socketController.eventData;
    //     if (eventData['event'] == 'user_typing') {
    //       debugPrint('ChatController: User typing: $eventData');
    //     } else {
    //       debugPrint('ChatController: Unknown event: $eventData');
    //     }
    //   }
    // });
  }

  @override
  void onInit() {
    super.onInit();

    apiService.onInit();
    // getInfoFromLocalStorage();
    fetchMessages();
    // recentsController.fetchRecents();
    watchSocketEvent();

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
      final response = await chat.getMessages(perPage: perPage, page: page);
      final jsonBody = jsonDecode(response.body);
      debugPrint("[RRSSD2] jsonBody: ${jsonBody.toString()}");
      final List<dynamic> rawMessages =
          (jsonBody['data']?['chat']['messages'] as List<dynamic>?) ??
          <dynamic>[];

      if (rawMessages.length < perPage) {
        hasMoreMessages = false;
      }

      final List<MessageModel> parsedMessages =
          rawMessages
              .map<MessageModel>(
                (dynamic message) =>
                    MessageModel.fromJson(message as Map<String, dynamic>),
              )
              .toList();

      // Merge with existing local messages to avoid duplicates
      final existingIds = messages.map((m) => m.id).toSet();
      final newMessages =
          parsedMessages.where((m) => !existingIds.contains(m.id)).toList();

      if (page == 1) {
        if (newMessages.isNotEmpty) {
          messages.addAll(newMessages);
        } else {
          messages.assignAll(parsedMessages);
        }
      } else {
        messages.addAll(newMessages);
      }

      // Sort messages by timestamp (oldest first)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
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
      debugPrint("[Chat Controller] added message: ${messages.toString()}");
    } catch (e) {
      debugPrint("[Chat Controller] Error sending message: $e");
    }
  }
}
