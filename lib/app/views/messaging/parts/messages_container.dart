import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/controllers/chat_controller.dart';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/messaging/parts/message_date.dart';

class MessagesContainer extends StatefulWidget {
  const MessagesContainer({super.key});

  @override
  State<MessagesContainer> createState() => _MessagesContainerState();
}

class _MessagesContainerState extends State<MessagesContainer> {
  final ScrollController _scrollController = ScrollController();
  late final ChatController chatController;

  @override
  void initState() {
    super.initState();
    chatController = Get.find<ChatController>();
    // Auto-scroll when messages list changes
    ever(chatController.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });

    ever(chatController.isKeyboardVisible, (_) {
      if (chatController.isKeyboardVisible.value) {
        // Delay the scroll to the bottom by 100 milliseconds
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToBottom();
        });
      }
    });

    // Scroll after first frame (initial load)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color getMessageColor(MessageModel message) {
      if (message.id == "sending") {
        return TalklinerThemeColors.primary025;
      }
      return message.isMe
          ? (isDarkMode ? TalklinerThemeColors.primary100 : TalklinerThemeColors.primary050)
          : (isDarkMode ? TalklinerThemeColors.gray700 : TalklinerThemeColors.gray040);
    }

    Color getMessageTextColor(MessageModel message) {
      if (message.id == "sending") {
        return TalklinerThemeColors.primary100;
      }
      return message.isMe
          ? (isDarkMode ? TalklinerThemeColors.primary800 : TalklinerThemeColors.primary700)
          : (isDarkMode ? TalklinerThemeColors.gray050 : TalklinerThemeColors.gray700);
    }

    return Obx(
      () => Container(
        decoration: BoxDecoration(color: isDarkMode ? TalklinerThemeColors.gray900 : TalklinerThemeColors.gray020),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          itemCount: chatController.messages.length,
          itemBuilder: (context, index) {
            final message = chatController.messages[index];
            final isMe = message.isMe;
            return Container(
              margin: EdgeInsets.only(
                top: index == 0 ? 0 : 8,
                bottom: 0,
                left: isMe ? 40 : 0,
                right: isMe ? 0 : 40,
              ),
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: getMessageColor(message),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(10),
                        topRight: const Radius.circular(10),
                        bottomLeft: Radius.circular(isMe ? 10 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 10),
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: getMessageTextColor(message),
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  (message.id == "sending")
                      ? Text(
                        "Sending...",
                        style: TextStyle(
                          color: TalklinerThemeColors.gray050,
                          fontSize: 12,
                        ),
                      )
                      : MessageDate(timestamp: message.timestamp),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
