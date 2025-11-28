import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/layout_controller.dart';
import 'package:talkliner/app/controllers/recents_controller.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/home/screens/recents/parts/new_screen.dart';
import 'package:talkliner/app/views/home/screens/recents/parts/recent_item_card.dart';

import 'package:talkliner/app/views/messaging/chat.dart';

class RecentScreen extends StatelessWidget {
  const RecentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recentsController = Get.find<RecentsController>();
    final layoutController = Get.find<LayoutController>();

    // Get Fresh Chats from the API
    recentsController.fetchRecents();

    Widget buildRecentsList(List<dynamic> items) {
      return RefreshIndicator(
        onRefresh: () async => recentsController.refreshRecents(),
        color: TalklinerThemeColors.primary500,
        backgroundColor: TalklinerThemeColors.primary025,
        strokeWidth: 2,
        elevation: 4,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder:
              (context, index) => Column(
                children: [
                  RecentItemCard(
                    recentItem: items[index],
                    onTapIconColor: Colors.red,
                    onTap: () => Get.to(() => Chat(chat: items[index])),
                    isSelected: false,
                  ),
                  Divider(height: 1),
                ],
              ),
        ),
      );
    }

    return Obx(
      () =>
          !recentsController.isLoading.value &&
                  recentsController.recents.isEmpty
              ? const NewScreen()
              : Column(
                children: [
                  ...layoutController.doAction('recent_screen'),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AnimatedBuilder(
                            animation: recentsController.tabController,
                            builder: (context, child) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildTabButton(
                                      context,
                                      title: "All",
                                      index: 0,
                                      controller:
                                          recentsController.tabController,
                                      icon: LucideIcons.messageCircle,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildTabButton(
                                      context,
                                      title: "users".tr,
                                      index: 1,
                                      controller:
                                          recentsController.tabController,
                                      icon: LucideIcons.user,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildTabButton(
                                      context,
                                      title: "groups".tr,
                                      index: 2,
                                      controller:
                                          recentsController.tabController,
                                      icon: LucideIcons.users,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(LucideIcons.search),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  Expanded(
                    child: TabBarView(
                      controller: recentsController.tabController,
                      children: [
                        buildRecentsList(recentsController.recents),
                        buildRecentsList(recentsController.userRecents),
                        buildRecentsList(recentsController.groupRecents),
                      ],
                    ),
                  ),
                ],
              ),
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
