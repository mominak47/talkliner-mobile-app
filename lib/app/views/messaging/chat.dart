import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/controllers/chat_controller.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/messaging/parts/message_input.dart';
import 'package:talkliner/app/views/messaging/parts/messages_container.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';

class Chat extends StatelessWidget {
  final UserModel user;
  const Chat({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.put(ChatController(user: user));

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDarkMode ? TalklinerThemeColors.gray800 : Colors.white,
        elevation: 0,
        toolbarHeight: 72,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: isDarkMode ? TalklinerThemeColors.gray050 : TalklinerThemeColors.gray800),
              onPressed: () => Navigator.of(context).pop(),
              splashRadius: 24,
            ),
            const SizedBox(width: 4),
            UserAvatar(user: user),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.displayName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? TalklinerThemeColors.gray050 : Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "Available",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode ? TalklinerThemeColors.gray050 : TalklinerThemeColors.gray600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.call_outlined,
                color: isDarkMode ? TalklinerThemeColors.gray050 : TalklinerThemeColors.gray800,
              ),
              onPressed: () {},
              splashRadius: 24,
            ),
            IconButton(
              icon: Icon(
                Icons.videocam_outlined,
                color: isDarkMode ? TalklinerThemeColors.gray050 : TalklinerThemeColors.gray800,
              ),
              onPressed: () {},
              splashRadius: 24,
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: isDarkMode ? TalklinerThemeColors.gray050 : TalklinerThemeColors.gray800),
              onPressed: () {},
              splashRadius: 24,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      backgroundColor: isDarkMode ? TalklinerThemeColors.gray800 : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: MessagesContainer()),
            MessageInput(),
          ],
        ),
      ),
    );
  }
}
