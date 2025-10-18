import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/config/routes.dart';
import 'package:talkliner/app/controllers/contacts_controller.dart';
import 'package:talkliner/app/views/home/widgets/signalbars_widget.dart';

class HomeController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxBool showAppBar = true.obs;

  // Get logo

  SvgPicture getLogo() {
    bool isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;
    if (isDarkMode) {
      return SvgPicture.asset('assets/logos/white_logo.svg', height: 36);
    } else {
      return SvgPicture.asset('assets/logos/talkliner.svg', height: 36);
    }
  }

  AppBar get _appbar => AppBar(
    title: getLogo(),
    actions: [
      SignalBarsWidget(),
      IconButton(
        onPressed: () => Get.toNamed(Routes.userSettings),
        icon: const Icon(LucideIcons.user),
      ),
    ],
  );

  RxBool showCustomAppBar = false.obs;

  AppBar _customAppBar = AppBar();

  @override
  void onInit() {
    super.onInit();
    currentIndex.listen((index) {
      if (index == 1) {
        Get.find<ContactsController>().changeTabBar("users");
      }else{
        showCustomAppBar.value = false;
      }
    });
  }

  void setCurrentIndex(int index) => currentIndex.value = index;

  void setShowAppBar(bool value) => showAppBar.value = value;

  void createAppBar(AppBar appbar) {
    _customAppBar = appbar;
    debugPrint("createAppBar");
    showCustomAppBar.value = true;
  }

  void removeCustomAppBar() {
    showCustomAppBar.value = false;
    _customAppBar = AppBar();
  } 

  AppBar getAppBar() {
    AppBar appBar = showCustomAppBar.value ? _customAppBar : _appbar;
    return appBar;
  }
}
