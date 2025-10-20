import 'package:get/get.dart';
import 'package:talkliner/app/config/routes.dart';
import 'package:talkliner/app/views/auth/login_view.dart';
import 'package:talkliner/app/views/auth/settings_view.dart';
import 'package:talkliner/app/views/calling/outgoing_call_screen.dart';
import 'package:talkliner/app/views/home/home_view.dart';
import 'package:talkliner/app/views/messaging/chat.dart';
import 'package:talkliner/app/views/others/splash_view.dart';
import 'package:talkliner/app/views/profile/user_settings.dart';

class Pages {
  static final List<GetPage> pages = [
    GetPage(
      name: Routes.splash,
      page: () => SplashView(),
    ),
    // Login Page
    GetPage(
      name: Routes.login,
      page: () => LoginView(),
    ),
    // Settings Page
    GetPage(
      name: Routes.settings,
      page: () => SettingsView(),
    ),
    // Home Page
    GetPage(
      name: Routes.home,
      page: () => HomeView(),
    ),
    // User Settings Page
    GetPage(
      name: Routes.userSettings,
      page: () => UserSettings(),
    ),
    // Chat Page
    GetPage(
      name: Routes.chat,
      page: () => Chat(
        user: Get.arguments,
      ),
    ),
    // Outgoing Call Page
    GetPage(
      name: Routes.outgoingCall,
      page: () => OutgoingCallScreen(
        user: Get.arguments
      ),
    ),
  ];
}
