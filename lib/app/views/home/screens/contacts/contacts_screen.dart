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

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contactsController = Get.find<ContactsController>();
    final pushToTalkController = Get.find<PushToTalkController>();
    final livekitRoomController = Get.find<LivekitRoomController>();
    final appSettingsController = Get.find<AppSettingsController>();
    final homeController = Get.find<HomeController>();

    contactsController.fetchContacts();
    contactsController.fetchGroups();

    Widget buildUsersList() {
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
                                pushToTalkController.selectedUser.value.id ==
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
                    onLongPress: () {},
                    onTapCard: () => Get.toNamed(Routes.chat, arguments: user),
                    isSelected:
                        pushToTalkController.selectedUser.value.id == user.id &&
                        !livekitRoomController.isRoomConnecting.value,
                  ),
                ),
                Divider(height: 1),
              ],
            );
          },
        ),
      );
    }

    Widget buildGroupsList() {
      return RefreshIndicator(
        color: TalklinerThemeColors.primary500,
        backgroundColor: TalklinerThemeColors.primary025,
        strokeWidth: 2,
        elevation: 4,
        onRefresh: () async => contactsController.refreshGroups(),
        key: contactsController.refreshGroupsIndicatorKey,
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
                                pushToTalkController.selectedUser.value.id ==
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
                        pushToTalkController.selectedUser.value.id == group.id,
                  ),
                ),
                Divider(height: 1),
              ],
            );
          },
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: contactsController.tabController,
                  builder: (context, child) {
                    return Row(
                      children: [
                        _buildTabButton(
                          context,
                          title: "users".tr,
                          index: 0,
                          controller: contactsController.tabController,
                          icon: LucideIcons.users,
                        ),
                        const SizedBox(width: 12),
                        _buildTabButton(
                          context,
                          title: "groups".tr,
                          index: 1,
                          controller: contactsController.tabController,
                          icon: LucideIcons.users,
                        ),
                      ],
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implement search functionality
                },
                icon: const Icon(LucideIcons.search),
                color: TalklinerThemeColors.gray900,
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: contactsController.tabController,
            children: [buildUsersList(), buildGroupsList()],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required String title,
    required int index,
    required TabController controller,
    required IconData icon,
  }) {
    final isSelected = controller.index == index;
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return ElevatedButton(
      onPressed: () {
        controller.animateTo(index);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor:
            isSelected
                ? TalklinerThemeColors.primary500
                : isLightMode
                ? TalklinerThemeColors.gray020
                : TalklinerThemeColors.gray700,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        overlayColor: TalklinerThemeColors.primary500,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color:
                isSelected
                    ? TalklinerThemeColors.gray700
                    : isLightMode
                    ? TalklinerThemeColors.gray800
                    : TalklinerThemeColors.gray020,
          ),
          SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              color:
                  isSelected
                      ? TalklinerThemeColors.gray700
                      : isLightMode
                      ? TalklinerThemeColors.gray800
                      : TalklinerThemeColors.gray020,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
