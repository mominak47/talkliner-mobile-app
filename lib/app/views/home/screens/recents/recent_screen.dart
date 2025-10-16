import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/controllers/recents_controller.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/home/screens/recents/parts/new_screen.dart';
import 'package:talkliner/app/views/home/screens/recents/parts/recent_item_card.dart';
import 'package:talkliner/app/views/home/widgets/tab_button.dart';
import 'package:talkliner/app/views/messaging/chat.dart';

class RecentScreen extends StatelessWidget {
  const RecentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recentsController = Get.find<RecentsController>();

    return Obx(
      () =>
          !recentsController.isLoading.value &&
                  recentsController.recents.isEmpty
              ? const NewScreen()
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            TabButton(
                              title: "All",
                              onTap: () {},
                              isSelected: false,
                            ),
                            SizedBox(width: 10),
                            TabButton(
                              title: "users".tr,
                              onTap: () {},
                              isSelected: false,
                            ),
                            SizedBox(width: 10),
                            TabButton(
                              title: "groups".tr,
                              onTap: () => {},
                              isSelected: false,
                            ),
                          ],
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
                    child: RefreshIndicator(
                      onRefresh: () async => recentsController.refreshRecents(),
                      color: TalklinerThemeColors.primary500,
                      backgroundColor: TalklinerThemeColors.primary025,
                      strokeWidth: 2,
                      elevation: 4,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: recentsController.recents.length,
                        itemBuilder:
                            (context, index) => Column(
                              children: [
                                RecentItemCard(
                                  recentItem: recentsController.recents[index],
                                  onTapIconColor: Colors.red,
                                  onTap:
                                      () => Get.to(
                                        () => Chat(
                                          user:
                                              recentsController
                                                  .recents[index]
                                                  .participants[0]
                                                  .user!,
                                        ),
                                      ),
                                  isSelected: false,
                                ),
                                Divider(
                                  height: 1,
                                ),
                              ],
                            ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
