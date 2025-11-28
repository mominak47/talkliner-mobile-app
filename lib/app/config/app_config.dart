import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class AppConfig {
  static const String name = 'Talkliner';
  static const String version = '1.0.0';
  static const String buildNumber = '1';
  static const int splashDelay = 300;

  // Use getter to avoid initialization issues with GetStorage
  String apiUrl() {
    try {
      final url = GetStorage().read('settings.apiUrl');
      debugPrint('[AppConfig] Read apiUrl from storage: $url');
      return url ?? 'https://api.talkliner.com/api';
    } catch (e) {
      debugPrint('[AppConfig] Error reading apiUrl: $e');
      // Return default if GetStorage not initialized yet
      return 'https://api.talkliner.com/api';
    }
  }

  String socketUrl() {
    try {
      String apiUrl = this.apiUrl().replaceAll('https://', '');
      apiUrl = apiUrl.replaceAll('/api', '');
      return 'https://$apiUrl';
    } catch (e) {
      // Return default if GetStorage not initialized yet
      return 'https://api.talkliner.com/';
    }
  }

  static const String livekitUrl = 'wss://talkliner-nh2ljes1.livekit.cloud';
  static const int pingInterval = 3;
}
