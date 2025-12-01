import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/socket_controller.dart';
import 'package:talkliner/app/models/group_model.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class GroupAvatar extends StatelessWidget {
  final GroupModel? group;
  final double size;
  final Color backgroundColor;
  final double fontSize;
  final Color textColor;
  final bool indicator;
  final String? whoIsSpeaking;
  final bool isTyping = false;

  const GroupAvatar({
    super.key,
    this.group,
    this.size = 48,
    this.backgroundColor = TalklinerThemeColors.gray080,
    this.fontSize = 16,
    this.textColor = Colors.white,
    this.indicator = true,
    this.whoIsSpeaking,
  });

  String getInitials() {
    if (group == null) {
      return "";
    }
    return group!.name.split(" ").map((e) => e[0]).join("");
  }

  Container getStatusIndicator(String whoIsSpeaking) {
    Color backgroundColor = TalklinerThemeColors.green500;
    Color iconColor = Colors.white;
    IconData icon = LucideIcons.check;

    return Container(
      clipBehavior: Clip.none,
      width: (1 / 3) * size,
      height: (1 / 3) * size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.white, width: 2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: (5.0 / 24.0) * size, color: iconColor),
    );
  }

  Container getTypingIndicator() {
    return Container(
      width: (1 / 3) * size,
      height: (1 / 3) * size,
      decoration: BoxDecoration(
        color: TalklinerThemeColors.primary500,
        shape: BoxShape.circle,
      ),
      child: Icon(
        LucideIcons.pencil,
        size: (5.0 / 24.0) * size,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final socketController = Get.find<SocketController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    RxBool typingState = false.obs;

    socketController.event.listen((event) {
      if (event == 'USER_TO_USER_EVENT') {
        if (socketController.eventData['event'] == 'user_typing') {
          typingState.value = socketController.eventData['data']['state'];
          debugPrint(
            "User Typing: ${typingState.value} : ${socketController.eventData['data']['text']}",
          );
        }
      }
    });

    // Return Circle with initials
    return Stack(
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor:
              isDarkMode ? TalklinerThemeColors.gray700 : backgroundColor,
          child: Text(
            getInitials(),
            style: TextStyle(fontSize: (1 / 3) * size, color: textColor),
          ),
        ),
        if (indicator)
          Obx(
            () => Positioned(
              bottom: 0,
              right: 0,
              child:
                  typingState.value
                      ? getTypingIndicator()
                      : getStatusIndicator(whoIsSpeaking ?? ""),
            ),
          ),
      ],
    );
  }
}
