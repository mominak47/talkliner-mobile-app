import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/controllers/livekit_room_controller.dart';
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

    final livekitRoomController = Get.find<LivekitRoomController>();

    final AuthController authController = Get.find<AuthController>();

    if (pushToTalkController.selectedUser.value.id == "" &&
        pushToTalkController.selectedGroup.value.id == "") {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isDarkMode
                      ? TalklinerThemeColors.gray700
                      : TalklinerThemeColors.gray030,
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
                color:
                    isDarkMode
                        ? TalklinerThemeColors.gray100
                        : TalklinerThemeColors.gray800,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    if (pushToTalkController.selectedUser.value.id != "") {
      return Obx(
        () => Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isDarkMode
                        ? TalklinerThemeColors.gray800
                        : TalklinerThemeColors.gray030,
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
                                pushToTalkController
                                    .selectedUser
                                    .value
                                    .displayName,
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? TalklinerThemeColors.gray020
                                          : TalklinerThemeColors.gray800,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                pushToTalkController.selectedUser.value.status
                                        .substring(0, 1)
                                        .toUpperCase() +
                                    pushToTalkController
                                        .selectedUser
                                        .value
                                        .status
                                        .substring(1),
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? TalklinerThemeColors.gray050
                                          : TalklinerThemeColors.gray500,
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
                          color:
                              isDarkMode
                                  ? TalklinerThemeColors.gray050
                                  : TalklinerThemeColors.gray500,
                          size: 24,
                        ),
                        onPressed: () {
                          if (pushToTalkController.selectedUser.value.id !=
                              "") {}
                        },
                      ),

                      // Video
                      IconButton(
                        icon: Icon(
                          LucideIcons.video,
                          color:
                              isDarkMode
                                  ? TalklinerThemeColors.gray050
                                  : TalklinerThemeColors.gray500,
                          size: 24,
                        ),
                        onPressed: () {},
                      ),

                      // Message
                      IconButton(
                        icon: Icon(
                          LucideIcons.messageSquare,
                          color:
                              isDarkMode
                                  ? TalklinerThemeColors.gray050
                                  : TalklinerThemeColors.gray500,
                          size: 24,
                        ),
                        onPressed: () {
                          if (pushToTalkController.selectedUser.value.id !=
                              "") {}
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Obx(
      () => Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isDarkMode
                          ? TalklinerThemeColors.gray800
                          : TalklinerThemeColors.gray030,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                isDarkMode
                                    ? TalklinerThemeColors.gray700
                                    : TalklinerThemeColors.gray050,
                            child: Text(
                              pushToTalkController.selectedGroup.value.name
                                  .substring(0, 1),
                              style: TextStyle(
                                color:
                                    isDarkMode
                                        ? TalklinerThemeColors.gray050
                                        : TalklinerThemeColors.gray500,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pushToTalkController
                                        .selectedGroup
                                        .value
                                        .name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color:
                                          isDarkMode
                                              ? TalklinerThemeColors.gray020
                                              : TalklinerThemeColors.gray800,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "Users ${pushToTalkController.selectedGroup.value.users.length}",
                                    style: TextStyle(
                                      color:
                                          isDarkMode
                                              ? TalklinerThemeColors.gray050
                                              : TalklinerThemeColors.gray500,
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
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 0,
                      children: [
                        IconButton(
                          icon: Icon(
                            LucideIcons.phone,
                            color:
                                isDarkMode
                                    ? TalklinerThemeColors.gray050
                                    : TalklinerThemeColors.gray500,
                            size: 24,
                          ),
                          onPressed: () {
                            if (pushToTalkController.selectedGroup.value.id !=
                                "") {}
                          },
                        ),

                        // Video
                        IconButton(
                          icon: Icon(
                            LucideIcons.video,
                            color:
                                isDarkMode
                                    ? TalklinerThemeColors.gray050
                                    : TalklinerThemeColors.gray500,
                            size: 24,
                          ),
                          onPressed: () {},
                        ),

                        // Message
                        IconButton(
                          icon: Icon(
                            LucideIcons.messageSquare,
                            color:
                                isDarkMode
                                    ? TalklinerThemeColors.gray050
                                    : TalklinerThemeColors.gray500,
                            size: 24,
                          ),
                          onPressed: () {
                            if (pushToTalkController.selectedGroup.value.id !=
                                "") {}
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            livekitRoomController.activeSpeaker.value != null
                ? "${livekitRoomController.activeSpeaker.value!.displayName} is speaking"
                : "",
          ),
        ],
      ),
    );
  }
}
