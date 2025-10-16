import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/config/routes.dart';
import 'package:talkliner/app/controllers/app_settings_controller.dart';
import 'package:talkliner/app/controllers/contacts_controller.dart';
import 'package:talkliner/app/controllers/home_controller.dart';
import 'package:talkliner/app/controllers/livekit_room_controller.dart';
import 'package:talkliner/app/controllers/push_to_talk_controller.dart';
import 'package:talkliner/app/models/group_model.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/home/screens/contacts/parts/contact_card.dart';
import 'package:talkliner/app/views/home/screens/contacts/parts/group_card.dart';
import 'package:talkliner/app/views/home/widgets/tab_button.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contactsController = Get.find<ContactsController>();
    final pushToTalkController = Get.find<PushToTalkController>();
    final livekitRoomController = Get.find<LivekitRoomController>();
    final appSettingsController = Get.find<AppSettingsController>();
    final homeController = Get.find<HomeController>();

    Widget getCurrentPage() {
      switch (contactsController.getSelectedTabBar()) {
        case "users":
          return RefreshIndicator(
            color: TalklinerThemeColors.primary500,
            backgroundColor: TalklinerThemeColors.primary025,
            strokeWidth: 2,
            elevation: 4,
            onRefresh: () async => contactsController.refreshContacts(),
            key: contactsController.refreshIndicatorKey,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount:
                  contactsController.contacts.length +
                  ((appSettingsController.showFloatingPushToTalkButton.value &&
                          homeController.currentIndex.value != 2)
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                if (index == contactsController.contacts.length &&
                    appSettingsController.showFloatingPushToTalkButton.value &&
                    homeController.currentIndex.value != 2) {
                  return const SizedBox(height: 100);
                }
                UserModel user = contactsController.contacts[index];
                return Column(
                  children: [
                    Obx(
                      () => ContactCard(
                        user: user,
                        onTapIcon:
                            livekitRoomController.isRoomConnecting.value &&
                                    pushToTalkController
                                            .selectedUser
                                            .value
                                            .id ==
                                        user.id
                                ? LucideIcons.loader
                                : LucideIcons.mic,
                        onTapIconColor: TalklinerThemeColors.red500,
                        onTap: () {
                          if (pushToTalkController.selectedUser.value.id ==
                              user.id) {
                            pushToTalkController.removeUser();
                          } else {
                            pushToTalkController.setUser(user);
                          }
                        },
                        onTapCard:
                            () => Get.toNamed(Routes.chat, arguments: user),
                        isSelected: pushToTalkController.selectedUser.value.id == user.id && !livekitRoomController.isRoomConnecting.value,
                      ),
                    ),
                    Divider(height: 1),
                  ],
                );
              },
            ),
          );
        case "groups":
          return RefreshIndicator(
            color: TalklinerThemeColors.primary500,
            backgroundColor: TalklinerThemeColors.primary025,
            strokeWidth: 2,
            elevation: 4,
            onRefresh: () async => contactsController.refreshGroups(),
            key: contactsController.refreshIndicatorKey,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount:
                  contactsController.groups.length +
                  ((appSettingsController.showFloatingPushToTalkButton.value &&
                          homeController.currentIndex.value != 2)
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                if (index == contactsController.groups.length &&
                    appSettingsController.showFloatingPushToTalkButton.value &&
                    homeController.currentIndex.value != 2) {
                  return const SizedBox(height: 100);
                }
                GroupModel group = contactsController.groups[index];
                return Column(
                  children: [
                    Obx(
                      () => GroupCard(
                        group: group,
                        onTapIcon:
                            livekitRoomController.isRoomConnecting.value &&
                                    pushToTalkController
                                            .selectedUser
                                            .value
                                            .id ==
                                        group.id
                                ? LucideIcons.loader
                                : LucideIcons.mic,
                        onTapIconColor: Colors.red,
                        onTap: () {
                          if (pushToTalkController.selectedUser.value.id ==
                              group.id) {
                            // pushToTalkController.removeUser();
                          } else {
                            // pushToTalkController.setUser(group);
                          }
                        },
                        onTapCard: () {},
                        isSelected:
                            pushToTalkController.selectedUser.value.id ==
                            group.id,
                      ),
                    ),
                    Divider(height: 1, color: TalklinerThemeColors.gray030),
                  ],
                );
              },
            ),
          );
        default:
          return const SizedBox.shrink();
      }
    }

    // In array condtion
    return Obx(
      () => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TabButton(
                      title: "Online",
                      onTap: () => contactsController.changeTabBar("users"),
                      isSelected:
                          contactsController.getSelectedTabBar() == "users",
                    ),
                    SizedBox(width: 10),
                    TabButton(
                      title: "users".tr,
                      onTap: () => contactsController.changeTabBar("users"),
                      isSelected:
                          contactsController.getSelectedTabBar() == "users",
                    ),
                    SizedBox(width: 10),
                    TabButton(
                      title: "groups".tr,
                      onTap: () => contactsController.changeTabBar("groups"),
                      isSelected:
                          contactsController.getSelectedTabBar() == "groups",
                    ),
                  ],
                ),
                !homeController.showCustomAppBar.value ? IconButton(
                  onPressed: () {
                    homeController.createAppBar(
                      AppBar(
                        title: SizedBox(
                          height: 48, // Fixed height for the search field
                          child: TextField(
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: "Search",
                              border: InputBorder.none,
                              prefixIcon: Icon(LucideIcons.search),
                              suffixIcon: IconButton(
                                icon: Icon(LucideIcons.xCircle),
                                onPressed: contactsController.clearSearch,
                              ),
                            ),
                            textInputAction: TextInputAction.search,
                          ),
                        ),

                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {
                              contactsController.changeTabBar("users");
                              homeController.removeCustomAppBar();
                            },
                            child: Text(
                              "cancel".tr,
                              style: TextStyle(
                                color: TalklinerThemeColors.primary500,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                        ],
                      ),
                    );
                  },
                  icon: Icon(LucideIcons.search),
                ) : SizedBox.shrink(),
              ],
            ),
          ),
          Divider(height: 1),
          // Use Expanded to allow the list to take available space and avoid overflow
          Expanded(child: getCurrentPage()),
        ],
      ),
    );
  }
}
