import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/controllers/recents_controller.dart';
import 'package:talkliner/app/controllers/socket_controller.dart';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/services/api_service.dart';

class ChatController extends GetxController {
  final UserModel user;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final ApiService apiService = ApiService();
  final isKeyboardVisible = false.obs;
  final isTyping = false.obs;

  final _audioPlayer = AudioPlayer();

  // Storage
  final GetStorage _storage = GetStorage();

  final RecentsController recentsController = Get.find<RecentsController>();

  ChatController({required this.user});
  final SocketController socketController = Get.find<SocketController>();
  final AuthController authController = Get.find<AuthController>();


  

  void watchSocketEvent() {
    socketController.event.listen((event) {
      if (event == 'new_message') {
        try {
          final eventData = socketController.eventData;
          if(
            eventData['message'] != null &&
            eventData['message']['sender_id']['_id'] != authController.user.value?.id
          ) {
            final message = MessageModel.fromJson(eventData['message']);
            // Check if message already exists to avoid duplicates
            if (!messages.any((m) => m.id == message.id)) {
              messages.add(message);
              // Save to local storage
              saveInfoInLocalStorage();
            }
          }
        } catch (e) {
          debugPrint('ChatController: Error parsing message: $e');
        }
      }

      if(event == 'USER_TO_USER_EVENT') {
        final eventData = socketController.eventData;
        if(eventData['event'] == 'user_typing') {
          debugPrint('ChatController: User typing: $eventData');
        }else{
          debugPrint('ChatController: Unknown event: $eventData');
        }
      }
    });
  }


  @override
  void onInit() {
    super.onInit();

    apiService.onInit();
    getInfoFromLocalStorage();
    fetchMessages(user.id);
    recentsController.fetchRecents();
    watchSocketEvent();
    
    ever(messages, (_) => {
      // If messages is not empty, save to local storage
      if(messages.isNotEmpty) {
        saveInfoInLocalStorage()
      }
    });
  }
  
  void emitUserTyping(bool state) {
    try {
      socketController.emitTo(user, 'user_typing', {
      'state': state,
      'from': authController.user.value!.id,
      });
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

  Future<void> fetchMessages(String userId) async {
    final response = await apiService.get('/chats/with/$userId');
    if (response.statusCode == 200) {
      debugPrint("[GETX] fetchMessages: ${response.body.toString()}");
      final List<dynamic> rawMessages = (response.body['data']?['messages'] as List<dynamic>?) ?? <dynamic>[];
      final List<MessageModel> parsedMessages = rawMessages
          .map<MessageModel>((dynamic message) => MessageModel.fromJson(message as Map<String, dynamic>))
          .toList();
      
      // Merge with existing local messages to avoid duplicates
      final existingIds = messages.map((m) => m.id).toSet();
      final newMessages = parsedMessages.where((m) => !existingIds.contains(m.id)).toList();
      
      if (newMessages.isNotEmpty) {
        messages.addAll(newMessages.reversed.toList());
      } else {
        // If no new messages, still update with server data to ensure consistency
        messages.assignAll(parsedMessages.reversed.toList());
      }
    }
  }

  Future<void> sendMessage(String userId, String content) async {
    // Add the message to the messages list
    messages.add(MessageModel(
      id: "sending",
      senderId: user.id,
      content: content,
      messageType: 'text',
      timestamp: DateTime.now(),
      edited: false,
      isMe: true,
    ));

    final response = await apiService.post('/chats/with/$userId/messages', {
      "content": content,
      "message_type": 'text',
      "file_url": null,
      "file_name": null,
      "file_size": null,
      "reply_to": null,
    });
    debugPrint("[GETX] sendMessage: ${response.body.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Play a sound
      _audioPlayer.play(AssetSource('audio/message-sent.mp3'));
      _audioPlayer.setReleaseMode(ReleaseMode.release);

      // Delete the message by id
      messages.removeWhere((message) => message.id == "sending");

      messages.add(MessageModel.fromJson(response.body['data']['message']));
      debugPrint("[GETX] added message: ${messages.toString()}");
    }
  }


  void saveInfoInLocalStorage() {
    try {
      final messagesJson = messages.map((m) => m.toJson()).toList();
      debugPrint("Saving To Local Storage : chat_${user.id}: ${messagesJson.length} messages");
      _storage.write('chat_${user.id}', messagesJson);
    } catch (e) {
      debugPrint("Error saving to local storage: $e");
    }
  }

  void getInfoFromLocalStorage() {
    try {
      final chatList = _storage.read('chat_${user.id}') ?? [];
      if (chatList is List && chatList.isNotEmpty) {
        final loadedMessages = chatList
            .map((chat) => MessageModel.fromJson(chat as Map<String, dynamic>))
            .toList();
        messages.assignAll(loadedMessages);
        debugPrint("Loaded From Local Storage: ${loadedMessages.length} messages");
      } else {
        debugPrint("No messages found in local storage for chat_${user.id}");
      }
    } catch (e) {
      debugPrint("Error loading from local storage: $e");
    }
  }

}