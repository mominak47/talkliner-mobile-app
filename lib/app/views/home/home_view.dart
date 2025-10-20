import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/controllers/app_settings_controller.dart';
import 'package:talkliner/app/controllers/home_controller.dart';
import 'package:talkliner/app/controllers/push_to_talk_controller.dart';
import 'package:talkliner/app/views/home/screens/contacts/contacts_screen.dart';
import 'package:talkliner/app/views/home/screens/map/map_screen.dart';
import 'package:talkliner/app/views/home/screens/news/news_screen.dart';
import 'package:talkliner/app/views/home/screens/pushtotalk/push_to_talk_screen.dart';
import 'package:talkliner/app/views/home/screens/pushtotalk/widgets/push_to_talk_button.dart';
import 'package:talkliner/app/views/home/screens/recents/recent_screen.dart';
import 'package:talkliner/app/views/home/widgets/navigation_bar.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final appSettingsController = Get.find<AppSettingsController>();
    final pushToTalkController = Get.find<PushToTalkController>();

    final List<Widget> screens = [
      RecentScreen(),
      ContactsScreen(),
      PushToTalkScreen(),
      MapScreen(),
      NewsScreen(),
    ];

    return Obx(
      () => Scaffold(
        appBar:
            homeController.showAppBar.value
                ? homeController.getAppBar()
                : null,
        body: SafeArea(
          child: Stack(
            children: [
              screens[homeController.currentIndex.value],
             
              if (appSettingsController.showFloatingPushToTalkButton.value &&
                  homeController.currentIndex.value != 2)
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: PushToTalkButton(
                    isDarkMode: Theme.of(context).brightness == Brightness.dark,
                    type: PushToTalkButtonType.bar,
                    buttonText:
                        "${pushToTalkController.selectedUser.value.displayName} : speaking",
                    onTapDown: () => pushToTalkController.startPTT(),
                    onTapUp: () => pushToTalkController.stopPTT(),
                    onLongPressStart: () {},
                    onLongPressEnd: () => pushToTalkController.stopPTT(),
                    state: pushToTalkController.getPTTButtonState(),
                    doWeNeedBorder: false,
                    doWeNeedShadows: false,
                    onTapCancel: () => pushToTalkController.stopPTT(),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(),
      ),
    );
  }
}
