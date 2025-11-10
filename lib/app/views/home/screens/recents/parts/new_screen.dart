import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ms_undraw/ms_undraw.dart';
import 'package:talkliner/app/config/routes.dart';
import 'package:talkliner/app/controllers/contacts_controller.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/home/screens/contacts/parts/contact_card.dart';

class NewScreen extends StatelessWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? TalklinerThemeColors.gray900 : Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UnDraw(
            color: TalklinerThemeColors.primary500,
            height: 150,
            illustration: UnDrawIllustration.construction_workers,
            placeholder: CircularProgressIndicator(),
            errorWidget: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 50,
            ), //optional, default is the Text('Could not load illustration!').
            useMemCache:
                true, // Use a memory cache to store the SVG files. Default is true.
            saveToDiskCache:
                true, // Save the SVG files to the disk cache. Default is true.
          ),
          Text(
            "Start Chatting",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? TalklinerThemeColors.gray100 : TalklinerThemeColors.gray800,
            ),
          ),
          Text(
            "Chat with your team members",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDarkMode ? TalklinerThemeColors.gray400 : TalklinerThemeColors.gray500,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Getx BottomSheet
              Get.bottomSheet(
                Container(
                  color: isDarkMode ? TalklinerThemeColors.gray900 : Colors.white,
                  width: double.infinity,
                  child: Column(
                    children: [
                      // Search Field
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search".tr,
                            fillColor: isDarkMode ? TalklinerThemeColors.gray900 : TalklinerThemeColors.gray020,
                            filled: true,
                            // No border
                            prefixIcon: Icon(LucideIcons.search),
                            suffixIcon: IconButton(
                              icon: Icon(LucideIcons.xCircle),
                              onPressed: () => Get.back(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Obx(() {
                          final contactsController =
                              Get.find<ContactsController>();
                          return ListView.builder(
                            itemCount: contactsController.contacts.length,
                            itemBuilder: (context, index) {
                              final user = contactsController.contacts[index];
                              return ContactCard(
                                user: user,
                                onTapIcon: LucideIcons.mic,
                                onTapIconColor: Colors.red,
                                onTap: () {},
                                onLongPress: () {},
                                onTapCard: () {
                                  // Close the bottom sheet
                                  Get.back();
                                  Get.toNamed(Routes.chat, arguments: user);
                                },
                                isSelected: false,
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                TalklinerThemeColors.primary500,
              ),
              foregroundColor: WidgetStateProperty.all(
                TalklinerThemeColors.gray900,
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            child: Text("Create Chat".tr),
          ),
        ],
      ),
    );
  }
}
