import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  Timer? localTimer;

  bool isKeyboardVisible = false;
  bool isMessageEmpty = true;

  @override
  void initState() {
    super.initState();
    chatController = Get.find<ChatController>();
    textController = TextEditingController();
    focusNode = FocusNode();

    focusNode.addListener(() {
      setState(() {
        isKeyboardVisible = focusNode.hasFocus;
      });

      if (focusNode.hasFocus) {
        // Local Message Check
        localTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (mounted) {
            if (textController.text.isEmpty ||
                textController.text.trim().isEmpty) {
              setState(() {
                isMessageEmpty = true;
              });
            } else {
              setState(() {
                isMessageEmpty = false;
              });
            }
          }
        });

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
    localTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? TalklinerThemeColors.gray800 : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // TextField with rounded border and hint
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      // vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color:
                          isDarkMode
                              ? TalklinerThemeColors.gray900
                              : TalklinerThemeColors.gray020,
                    ),
                    child: TextField(
                      controller: textController,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: null,
                      minLines: 1,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        fillColor:
                            isDarkMode
                                ? TalklinerThemeColors.gray900
                                : TalklinerThemeColors.gray020,
                        filled: true,
                        hintText: "Type a message...",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color:
                              isDarkMode
                                  ? TalklinerThemeColors.gray050
                                  : TalklinerThemeColors.gray100,
                        ),
                        focusColor: Colors.transparent,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        border: InputBorder.none,
                        isDense: false,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                if (!isMessageEmpty)
                  ElevatedButton(
                    onPressed: () {
                      // chatController.sendMessage(
                      //   chatController.user.id,
                      //   textController.text,
                      // );
                      textController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TalklinerThemeColors.primary500,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/send-horizontal-filled.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),

                // Attachment icon
                if (isMessageEmpty)
                  IconButton(
                    icon: Icon(
                      LucideIcons.paperclip,
                      size: 20,
                      color:
                          isDarkMode
                              ? TalklinerThemeColors.gray050
                              : TalklinerThemeColors.gray500,
                    ),
                    onPressed: () {},
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                // Camera icon
                if (isMessageEmpty)
                  IconButton(
                    icon: Icon(
                      LucideIcons.camera,
                      size: 20,
                      color:
                          isDarkMode
                              ? TalklinerThemeColors.gray050
                              : TalklinerThemeColors.gray500,
                    ),
                    onPressed: () {},
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
