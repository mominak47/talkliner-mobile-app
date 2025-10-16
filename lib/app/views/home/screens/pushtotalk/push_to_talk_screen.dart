import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/livekit_room_controller.dart';
import 'package:talkliner/app/controllers/push_to_talk_controller.dart';
import 'package:talkliner/app/controllers/socket_controller.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/home/screens/pushtotalk/widgets/push_to_talk_button.dart';
import 'package:talkliner/app/views/home/screens/pushtotalk/widgets/selected_user.dart';

class PushToTalkScreen extends StatefulWidget {
  const PushToTalkScreen({super.key});

  @override
  State<PushToTalkScreen> createState() => _PushToTalkScreenState();
}

class _PushToTalkScreenState extends State<PushToTalkScreen> {
  final socketController = Get.find<SocketController>();
  final pushToTalkController = Get.find<PushToTalkController>();
  final livekitRoomController = Get.find<LivekitRoomController>();

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
                SelectedUser(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Volume control button
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: isDarkMode ? TalklinerThemeColors.gray800 : TalklinerThemeColors.gray020,
                          shape: const CircleBorder(),
                        ),
                        icon: Icon(
                          LucideIcons.volume2,
                          color: isDarkMode ? TalklinerThemeColors.gray100 : TalklinerThemeColors.gray700,
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
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                // Text("Room Name: ${livekitRoomController.roomName.value}"),
                // Text("Is Room Connecting: ${livekitRoomController.isRoomConnecting.value.toString()}"),
                // Text("Is Connected: ${livekitRoomController.isConnected.value.toString()}"),
                // Text("Is Room Connecting: ${livekitRoomController.isRoomConnecting.value.toString()}"),
       
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
                    doWeNeedShadows: true,
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
}
