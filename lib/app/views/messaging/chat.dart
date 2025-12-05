import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/controllers/chat_controller.dart';
import 'package:talkliner/app/controllers/recents_controller.dart';
import 'package:talkliner/app/controllers/socket_controller.dart';
import 'package:talkliner/app/helpers/global_helpers.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/calling/outgoing_call_screen.dart';
import 'package:talkliner/app/views/messaging/parts/message_input.dart';
import 'package:talkliner/app/views/messaging/parts/messages_container.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';

class Chat extends StatefulWidget {
  final ChatModel chat;
  const Chat({super.key, required this.chat});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  void initState() {
    super.initState();
    final chatController = Get.put(ChatController(chat: widget.chat));
    // chatController.getMessagesFromStorage();
    chatController.fetchMessages();
    debugPrint("Chat Init");
  }

  @override
  void dispose() {
    super.dispose();
    RecentsController().getChatsFromDatabase();
  }

  Widget getProfilePicture(chat) {
    Widget profilePicture = SizedBox();
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (chat.chatType == ChatType.individual && chat.participants.isNotEmpty) {
      profilePicture = UserAvatar(user: chat.participants[0].user!);
    }

    if (chat.chatType == ChatType.group) {
      profilePicture = CircleAvatar(
        radius: 24,
        backgroundColor:
            isDarkMode
                ? TalklinerThemeColors.gray900
                : TalklinerThemeColors.gray020,
        child: Icon(Icons.group, color: TalklinerThemeColors.gray050),
      );
    }

    return GestureDetector(
      onTap: () => GobalHelpers.showChatInformation(chat),
      child: profilePicture,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final socketController = Get.find<SocketController>();

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:
            isDarkMode ? TalklinerThemeColors.gray800 : Colors.white,
        elevation: 0,
        toolbarHeight: 72,
        titleSpacing: 0,
        title: Obx(
          () => Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color:
                      isDarkMode
                          ? TalklinerThemeColors.gray050
                          : TalklinerThemeColors.gray800,
                ),
                onPressed: () => Navigator.of(context).pop(),
                splashRadius: 24,
              ),
              const SizedBox(width: 4),
              getProfilePicture(chat),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      chat.chatType == ChatType.individual &&
                              chat.participants.isNotEmpty
                          ? chat.participants[0].user!.displayName
                          : chat.name!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color:
                            isDarkMode
                                ? TalklinerThemeColors.gray050
                                : Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Available",
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                isDarkMode
                                    ? TalklinerThemeColors.gray050
                                    : TalklinerThemeColors.gray600,
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
                  color:
                      isDarkMode
                          ? (socketController.isConnected.value
                              ? TalklinerThemeColors.gray020
                              : TalklinerThemeColors.gray900)
                          : (socketController.isConnected.value
                              ? TalklinerThemeColors.gray900
                              : TalklinerThemeColors.gray050),
                ),
                onPressed: () {
                  if (socketController.isConnected.value) {
                    // Get.toNamed(Routes.outgoingCall, arguments: chat);
                    Get.to(() => OutgoingCallScreen(chat: chat));
                  } else {
                    Fluttertoast.showToast(
                      msg: 'You are not connected to the internet',
                    );
                  }
                },
                splashRadius: 24,
              ),
              IconButton(
                icon: Icon(
                  Icons.videocam_outlined,
                  color:
                      isDarkMode
                          ? (socketController.isConnected.value
                              ? TalklinerThemeColors.gray020
                              : TalklinerThemeColors.gray900)
                          : (socketController.isConnected.value
                              ? TalklinerThemeColors.gray900
                              : TalklinerThemeColors.gray050),
                ),
                onPressed: () {
                  if (socketController.isConnected.value) {
                    // Get.toNamed(Routes.outgoingCall, arguments: user);
                  } else {
                    Fluttertoast.showToast(
                      msg: 'You are not connected to the internet',
                    );
                  }
                },
                splashRadius: 24,
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color:
                      isDarkMode
                          ? TalklinerThemeColors.gray050
                          : TalklinerThemeColors.gray800,
                ),
                onPressed: () {},
                splashRadius: 24,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      backgroundColor: isDarkMode ? TalklinerThemeColors.gray800 : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: MessagesContainer(chat: chat)),
            MessageInput(chat: chat),
          ],
        ),
      ),
    );
  }
}
