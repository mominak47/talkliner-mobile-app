import 'package:get/get.dart';

class AppLifecycleController extends FullLifeCycleController {
  @override
  void onResumed() {
    print("App is ACTIVE (Foreground)");
    // Logic for when user returns to the app
  }

  @override
  void onPaused() {
    print("App is IN BACKGROUND");
    // Logic for when user leaves the app
  }

  @override
  void onInactive() {
    print("App is INACTIVE (e.g., during a system alert)");
  }

  @override
  void onDetached() {
    print("App is DETACHED");
  }
}
