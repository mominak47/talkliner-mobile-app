import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/call_controller.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';

class OutgoingCallScreen extends StatelessWidget {
  final ChatModel chat;
  final bool isVideo;

  const OutgoingCallScreen({
    super.key,
    required this.chat,
    this.isVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    final CallController callController = Get.find<CallController>();
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    UserModel user = chat.participants[0].user!;

    callController.startOutgoingCall(user, isVideo: isVideo);

    String getName() {
      if (chat.chatType == ChatType.group) {
        return chat.name!;
      } else {
        return chat.participants[0].user!.displayName;
      }
    }

    return Scaffold(
      body: Obx(() {
        return SafeArea(
          child: Column(
            children: [
              Spacer(),
              Center(
                child:
                    (chat.chatType == ChatType.group)
                        ? CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              isDarkMode
                                  ? Colors.white
                                  : TalklinerThemeColors.gray030,
                          child: Text(
                            chat.name!.split(" ").map((e) => e[0]).join(""),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        : UserAvatar(
                          user: chat.participants[0].user,
                          size: 100,
                          indicator: false,
                        ),
              ),
              SizedBox(height: 20),
              Text(
                getName(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                callController.activeCall.value?.status.displayName ?? '',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              if (callController.outGoingCallStatus.value == "No Answer")
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          isDarkMode
                              ? Colors.white
                              : TalklinerThemeColors.gray030,
                      child: IconButton(
                        iconSize: 24,
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(LucideIcons.x, color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 12),
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: TalklinerThemeColors.green500,
                      child: IconButton(
                        iconSize: 24,
                        onPressed: () => callController.retryCall(),
                        icon: Icon(
                          LucideIcons.phoneOutgoing,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

              if (callController.activeCall.value != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          isDarkMode
                              ? Colors.white
                              : TalklinerThemeColors.gray030,
                      child: IconButton(
                        iconSize: 24,
                        onPressed: () {},
                        icon: Icon(Icons.mic, color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 12),
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          isDarkMode
                              ? Colors.white
                              : TalklinerThemeColors.gray030,
                      child: IconButton(
                        iconSize: 24,
                        onPressed: () {},
                        icon: Icon(Icons.mic_off, color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 12),
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: TalklinerThemeColors.red500,
                      child: IconButton(
                        iconSize: 24,
                        onPressed: () {
                          callController.endCall(
                            callController.activeCall.value,
                          );
                          Get.back();
                        },
                        icon: Icon(LucideIcons.x, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}
