import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/call_controller.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';

class OutgoingCallScreen extends StatelessWidget {
  final UserModel user;
  const OutgoingCallScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final CallController callController = Get.find<CallController>();
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    callController.startOutgoingCall(user);

    return Scaffold(
      body: Obx(() {
        return SafeArea(
          child: Column(
            children: [
              Spacer(),
              Center(
                child: UserAvatar(user: user, size: 100, indicator: false),
              ),
              SizedBox(height: 20),
              Text(
                user.displayName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                callController.outGoingCallStatus.value,
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
                      icon: Icon(LucideIcons.phoneOutgoing, color: Colors.white),
                    ),
                  ),
                ],
              ),

              if (callController.outGoingCallStatus.value != "No Answer")
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
                          callController.endCall();
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
