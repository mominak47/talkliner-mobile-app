import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/chat_controller.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({super.key});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late final ChatController chatController;
  late final TextEditingController textController;
  late final FocusNode focusNode;
  Timer? typingTimer;

  @override
  void initState() {
    super.initState();
    chatController = Get.find<ChatController>();
    textController = TextEditingController();
    focusNode = FocusNode();

    focusNode.addListener(() {
      chatController.isKeyboardVisible.value = focusNode.hasFocus;
      if (focusNode.hasFocus) {
        typingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
          if (textController.text.isEmpty ||
              textController.text.trim().isEmpty ||
              textController.text.trim().length < 2) {
            chatController.emitUserTyping(false);
          } else {
            chatController.emitUserTyping(true);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    typingTimer?.cancel();
    textController.dispose();
    focusNode.dispose();
    chatController.emitUserTyping(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      width: double.infinity,
      decoration: BoxDecoration(
        // border: Border(top: BorderSide(color: isDarkMode ? TalklinerThemeColors.gray050 : TalklinerThemeColors.gray030)),
        color: isDarkMode ? TalklinerThemeColors.gray800 : Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // TextField with rounded border and hint
              Expanded(
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isDarkMode ? TalklinerThemeColors.gray900 : Colors.white,
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: textController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.send,
                    focusNode: focusNode,
                    onEditingComplete: () {
                      chatController.sendMessage(
                        chatController.user.id,
                        textController.text,
                      );
                      textController.clear();
                    },
                    decoration: InputDecoration(
                      fillColor: isDarkMode ? TalklinerThemeColors.gray900 : Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      hintText: "Type a message...",
                      hintStyle: TextStyle(fontSize: 14, color: isDarkMode ? TalklinerThemeColors.gray050 : TalklinerThemeColors.gray100),
                      focusColor: Colors.transparent,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Attachment icon
              IconButton(
                icon: Icon(
                  LucideIcons.paperclip,
                  size: 22,
                  color: isDarkMode ? TalklinerThemeColors.gray050 : TalklinerThemeColors.gray500,
                ),
                onPressed: () {},
                splashRadius: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              // Camera icon
              IconButton(
                icon: Icon(
                  LucideIcons.camera,
                  size: 22,
                  color: isDarkMode ? TalklinerThemeColors.gray050 : TalklinerThemeColors.gray500,
                ),
                onPressed: () {},
                splashRadius: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
