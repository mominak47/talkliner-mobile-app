import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/push_to_talk_controller.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';

class SelectedUser extends StatelessWidget {
  const SelectedUser({super.key});

  @override
  Widget build(BuildContext context) {
    final pushToTalkController = Get.find<PushToTalkController>();
    // Is light mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (pushToTalkController.selectedUser.value.id == "") {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:isDarkMode ? TalklinerThemeColors.gray700 : TalklinerThemeColors.gray030,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              "select_user_or_group_for_ptt_connection".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDarkMode ? TalklinerThemeColors.gray100 : TalklinerThemeColors.gray800,
                fontSize: 14,
              ),
            ),
          )
        ),
      );
    }

    return Obx(
      () => Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:isDarkMode ? TalklinerThemeColors.gray800 : TalklinerThemeColors.gray030,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  UserAvatar(user: pushToTalkController.selectedUser.value),
                  SizedBox(width: 16),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pushToTalkController.selectedUser.value.displayName,
                            style: TextStyle(
                              color: isDarkMode ? TalklinerThemeColors.gray100 : TalklinerThemeColors.gray800,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            pushToTalkController.selectedUser.value.status,
                            style: TextStyle(
                              color: isDarkMode ? TalklinerThemeColors.gray400 : TalklinerThemeColors.gray500,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 0,
                children: [
                  IconButton(
                    icon: Icon(
                      LucideIcons.phone,
                      color:TalklinerThemeColors.gray500,
                      size: 24,
                    ),
                    onPressed: () {
                      if (pushToTalkController.selectedUser.value.id != "") {
                      }
                    },
                  ),

                  // Video
                  IconButton(
                    icon: Icon(
                      LucideIcons.video,
                      color: TalklinerThemeColors.gray500,
                      size: 24,
                    ),
                    onPressed: () {
                    },
                  ),

                  // Message
                  IconButton(
                    icon: Icon(
                      LucideIcons.messageSquare,
                      color:TalklinerThemeColors.gray500,
                      size: 24,
                    ),
                    onPressed: () {
                      if (pushToTalkController.selectedUser.value.id != "") {
                       
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
    );
  }
}
