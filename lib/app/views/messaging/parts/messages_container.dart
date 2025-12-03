import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/controllers/chat_controller.dart';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/messaging/parts/message_date.dart';

import 'package:talkliner/app/views/messaging/parts/date_divider.dart';

class MessagesContainer extends StatefulWidget {
  const MessagesContainer({super.key});

  @override
  State<MessagesContainer> createState() => _MessagesContainerState();
}

class _MessagesContainerState extends State<MessagesContainer> {
  final ScrollController _scrollController = ScrollController();
  late final ChatController chatController;
  bool _pageOpened = false;

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

    // Scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 50) {
        // chatController.loadMoreMessages();
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

    if (!_pageOpened) {
      // Scroll without animation
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      _pageOpened = true;
    } else {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
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
          ? (isDarkMode
              ? TalklinerThemeColors.primary100
              : TalklinerThemeColors.primary050)
          : (isDarkMode
              ? TalklinerThemeColors.gray700
              : TalklinerThemeColors.gray040);
    }

    Color getMessageTextColor(MessageModel message) {
      if (message.id == "sending") {
        return TalklinerThemeColors.primary100;
      }
      return message.isMe
          ? (isDarkMode
              ? TalklinerThemeColors.primary800
              : TalklinerThemeColors.primary700)
          : (isDarkMode
              ? TalklinerThemeColors.gray050
              : TalklinerThemeColors.gray700);
    }

    bool shouldShowDateDivider(int index) {
      if (index == 0) return true;
      final currentMessage = chatController.messages[index];
      final previousMessage = chatController.messages[index - 1];

      final currentDate = DateTime(
        currentMessage.timestamp.year,
        currentMessage.timestamp.month,
        currentMessage.timestamp.day,
      );
      final previousDate = DateTime(
        previousMessage.timestamp.year,
        previousMessage.timestamp.month,
        previousMessage.timestamp.day,
      );

      return currentDate != previousDate;
    }

    return Obx(
      () => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? TalklinerThemeColors.gray900
                    : TalklinerThemeColors.gray020,
          ),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: chatController.messages.length,
            itemBuilder: (context, index) {
              final message = chatController.messages[index];
              final isMe = message.isMe;
              final showDateDivider = shouldShowDateDivider(index);

              return Column(
                children: [
                  if (index == 0 && chatController.isLoadingMore.value)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  if (showDateDivider)
                    DateDivider(timestamp: message.timestamp),
                  Container(
                    margin: EdgeInsets.only(
                      top: showDateDivider ? 0 : (index == 0 ? 0 : 8),
                      bottom: 0,
                      left: isMe ? 40 : 0,
                      right: isMe ? 0 : 40,
                    ),
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment:
                          isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
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
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
