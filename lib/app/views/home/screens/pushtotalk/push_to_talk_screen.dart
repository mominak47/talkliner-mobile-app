import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/call_controller.dart';
import 'package:talkliner/app/controllers/contacts_controller.dart';
import 'package:talkliner/app/controllers/emergency_controller.dart';
import 'package:talkliner/app/controllers/livekit_room_controller.dart';
import 'package:talkliner/app/controllers/push_to_talk_controller.dart';
import 'package:talkliner/app/controllers/socket_controller.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/home/screens/pushtotalk/widgets/push_to_talk_button.dart';
import 'package:talkliner/app/views/home/screens/pushtotalk/widgets/selected_user.dart';
import 'package:talkliner/app/views/others/components/user_avatar.dart';

class PushToTalkScreen extends StatefulWidget {
  const PushToTalkScreen({super.key});

  @override
  State<PushToTalkScreen> createState() => _PushToTalkScreenState();
}

class _PushToTalkScreenState extends State<PushToTalkScreen> {
  final socketController = Get.find<SocketController>();
  final pushToTalkController = Get.find<PushToTalkController>();
  final livekitRoomController = Get.find<LivekitRoomController>();
  final callController = Get.find<CallController>();
  final emergencyController = Get.put(EmergencyController());
  final contactsController = Get.find<ContactsController>();

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Obx(
        () => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section with contact info and control buttons
            Column(
              children: [
                callController.activeCall.value != null
                    ? callController.getCallInProgressWidget()
                    : SizedBox(),
                SelectedUser(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Volume control button
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor:
                              isDarkMode
                                  ? TalklinerThemeColors.gray800
                                  : TalklinerThemeColors.gray020,
                          shape: const CircleBorder(),
                        ),
                        icon: Icon(
                          LucideIcons.volume2,
                          color:
                              isDarkMode
                                  ? TalklinerThemeColors.gray100
                                  : TalklinerThemeColors.gray700,
                          size: 24,
                        ),
                        onPressed: () {
                          debugPrint("Volume Button");
                        },
                      ),

                      // Alert/emergency button
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: TalklinerThemeColors.red500,
                          shape: const CircleBorder(),
                        ),
                        icon: const Icon(
                          LucideIcons.alertTriangle,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          emergencyController.triggerEmergency();
                        },
                      ),
                    ],
                  ),
                ),
                _buildFavoritesList(context),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  child: PushToTalkButton(
                    isDarkMode: Theme.of(context).brightness == Brightness.dark,
                    buttonText: 'Push to Talk',
                    onTapDown: () => pushToTalkController.startPTT(),
                    onTapUp: () => pushToTalkController.stopPTT(),
                    onLongPressStart: () {},
                    onLongPressEnd: () => pushToTalkController.stopPTT(),
                    onTapCancel: () => pushToTalkController.stopPTT(),
                    state: pushToTalkController.getPTTButtonState(),
                    type: PushToTalkButtonType.main,
                    doWeNeedBorder: true,
                    doWeNeedShadows: false,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final favorites = contactsController.favoriteContacts;
      if (favorites.isEmpty) return SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Favorites",
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: favorites.length,
              separatorBuilder: (context, index) => SizedBox(width: 16),
              itemBuilder: (context, index) {
                UserModel user = favorites[index];
                bool isSelected =
                    pushToTalkController.selectedUser.value.id == user.id;

                return GestureDetector(
                  onTap: () => pushToTalkController.setUser(user),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              isSelected
                                  ? Border.all(
                                    color: TalklinerThemeColors.primary500,
                                    width: 2,
                                  )
                                  : null,
                        ),
                        padding: EdgeInsets.all(2),
                        child: UserAvatar(user: user, size: 48),
                      ),
                      SizedBox(height: 4),
                      SizedBox(
                        width: 60,
                        child: Text(
                          user.displayName.split(' ')[0],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isSelected
                                    ? TalklinerThemeColors.primary500
                                    : (isDarkMode
                                        ? Colors.white
                                        : Colors.black),
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
