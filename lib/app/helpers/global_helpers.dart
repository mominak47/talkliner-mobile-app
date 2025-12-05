import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/models/chat_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class GobalHelpers {
  static void showChatInformation(ChatModel chat) {
    bool isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;

    Widget _getTabButton(String name, bool isActive) {
      return ElevatedButton(
        onPressed: () {},
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            isDarkMode
                ? (isActive
                    ? TalklinerThemeColors.primary500
                    : TalklinerThemeColors.gray900)
                : (isActive ? TalklinerThemeColors.primary500 : Colors.white),
          ),
          elevation: WidgetStateProperty.all(0),
          surfaceTintColor: WidgetStateProperty.all(
            TalklinerThemeColors.primary500,
          ),
          foregroundColor: WidgetStateProperty.all(
            isDarkMode
                ? TalklinerThemeColors.gray100
                : TalklinerThemeColors.gray800,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 13,
            color:
                isDarkMode
                    ? (isActive
                        ? TalklinerThemeColors.gray900
                        : TalklinerThemeColors.gray200)
                    : (isActive
                        ? TalklinerThemeColors.gray900
                        : TalklinerThemeColors.gray200),
          ),
        ),
      );
    }

    // Show Getx Bottomsheet
    Get.bottomSheet(
      Container(
        color: isDarkMode ? TalklinerThemeColors.gray900 : Colors.white,
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(height: 8),
            SizedBox(
              height: 3,
              width: 100,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? TalklinerThemeColors.gray600
                          : TalklinerThemeColors.gray200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 8),

            // Tabs : Info, Members, Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _getTabButton("Info", true)),
                  SizedBox(width: 8),
                  Expanded(child: _getTabButton("Members", false)),
                  SizedBox(width: 8),
                  Expanded(child: _getTabButton("Settings", false)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
