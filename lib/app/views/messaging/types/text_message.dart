import 'package:flutter/material.dart';
import 'package:talkliner/app/models/message_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/messaging/message_helper.dart';
import 'package:talkliner/app/views/messaging/parts/message_date.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({super.key, required this.message});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    bool isMe = message.isMe;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: MessageHelper.getMessageColor(message, isDarkMode),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10),
              topRight: const Radius.circular(10),
              bottomLeft: Radius.circular(isMe ? 10 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: MessageHelper.getMessageTextColor(message, isDarkMode),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        (message.id == "sending")
            ? Text(
              "Sending...",
              style: TextStyle(
                color: TalklinerThemeColors.gray050,
                fontSize: 12,
              ),
            )
            : MessageDate(timestamp: message.timestamp),
      ],
    );
  }
}
