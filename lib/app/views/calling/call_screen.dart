import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/call_controller.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CallController callController = Get.find<CallController>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? TalklinerThemeColors.gray900 : Colors.white,
      body: SafeArea(
        child: Obx(() {
          final call = callController.activeCall.value;

          if (call == null) {
            return Center(child: Text("No Active Call"));
          }

          final user = call.participants.first;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              UserAvatar(user: user, size: 120, indicator: false),
              SizedBox(height: 24),
              Text(
                user.displayName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                call.status.displayName,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              Spacer(),
              // Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute
                    IconButton(
                      onPressed: callController.toggleMute,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            callController.isMuted.value
                                ? Colors.white
                                : Colors.transparent,
                        padding: EdgeInsets.all(12),
                      ),
                      icon: Icon(
                        callController.isMuted.value
                            ? LucideIcons.micOff
                            : LucideIcons.mic,
                        size: 32,
                        color:
                            callController.isMuted.value
                                ? Colors.black
                                : (isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
                    // End Call
                    FloatingActionButton(
                      backgroundColor: Colors.red,
                      onPressed: () => callController.endCall(call),
                      child: Icon(LucideIcons.phoneOff, color: Colors.white),
                    ),
                    // Speaker (Placeholder)
                    IconButton(
                      onPressed: () {
                        // Placeholder for speaker
                      },
                      icon: Icon(
                        LucideIcons.volume2,
                        size: 32,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
