import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/controllers/chat_controller.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/sql_tables/chat_table.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/messaging/parts/message_date.dart';

import 'package:talkliner/app/views/messaging/parts/date_divider.dart';

class MessagesContainer extends StatefulWidget {
  final ChatModel chat;
  const MessagesContainer({super.key, required this.chat});

  @override
  State<MessagesContainer> createState() => _MessagesContainerState();
}

class _MessagesContainerState extends State<MessagesContainer> {
  final ScrollController _scrollController = ScrollController();
  late final ChatController chatController;
  List<UserModel> participants = [];

  @override
  void initState() {
    super.initState();
    chatController = Get.find<ChatController>();

    getParticipants();

    // Auto-scroll when messages list changes
    ever(chatController.messages, (_) {
      // When a new message is added, it appears at index 0 (bottom), so we scroll to 0
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
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        // chatController.loadMoreMessages();
      }
    });
  }

  void getParticipants() async {
    var participants = await ChatTable().getChatParticipants(widget.chat.id);
    if (participants != null) {
      setState(() {
        participants = participants;
      });
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      0.0, // 0.0 is the bottom in a reversed list
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
      // In reversed list, index is 0 at the bottom (newest).
      // We want to compare current message with the one *before* it chronologically.
      // Chronologically previous message is at index + 1 in the reversed list.

      // If it's the last item in the reversed list (oldest message), show date.
      if (index == chatController.messages.length - 1) return true;

      final currentMessage =
          chatController.messages[chatController.messages.length - 1 - index];
      final previousMessage =
          chatController.messages[chatController.messages.length -
              1 -
              (index + 1)];

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

    Widget _showUser(message) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? TalklinerThemeColors.gray800
                  : TalklinerThemeColors.gray050,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 8,
              backgroundColor:
                  isDarkMode
                      ? TalklinerThemeColors.gray050
                      : TalklinerThemeColors.gray100,
              child: Icon(
                Icons.person,
                color:
                    isDarkMode
                        ? TalklinerThemeColors.gray500
                        : TalklinerThemeColors.gray050,
                size: 8,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              message.displayName ?? "Unknown",
              style: TextStyle(
                color: TalklinerThemeColors.gray200,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
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
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: chatController.messages.length,
            itemBuilder: (context, index) {
              // Reverse index mapping: 0 -> last item (newest)
              final message =
                  chatController.messages[chatController.messages.length -
                      1 -
                      index];
              final isMe = message.isMe;
              final showDateDivider = shouldShowDateDivider(index);

              return Column(
                children: [
                  if (showDateDivider)
                    DateDivider(timestamp: message.timestamp),
                  Container(
                    margin: EdgeInsets.only(
                      top: showDateDivider ? 0 : 8, // Adjusted margin logic
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              !isMe && widget.chat.chatType == ChatType.group
                                  ? _showUser(message)
                                  : const SizedBox(),
                              !isMe && widget.chat.chatType == ChatType.group
                                  ? const SizedBox(height: 8)
                                  : const SizedBox(),
                              Text(
                                message.content,
                                style: TextStyle(
                                  color: getMessageTextColor(message),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
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
                  if (index == chatController.messages.length - 1 &&
                      chatController.isLoadingMore.value)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
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
