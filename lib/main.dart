import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'package:talkliner/app/config/app_bindings.dart';
import 'package:talkliner/app/config/pages.dart';
import 'package:talkliner/app/config/routes.dart';
import 'package:talkliner/app/language/app_language.dart';
import 'package:talkliner/app/themes/app_theme.dart';
import 'package:talkliner/app/services/fcm_service.dart';
import 'firebase_options.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  try {
    // Initialize Flutter bindings
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase Core
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('[MAIN] Firebase initialized successfully');

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize GetStorage first
    await GetStorage.init();
    debugPrint('[MAIN] GetStorage initialized successfully');

    // Initialize FCM Service (includes local notifications setup)
    try {
      await FCMService.initialize();
      debugPrint('[MAIN] FCM Service initialized successfully');
    } catch (e) {
      debugPrint('[MAIN] FCM Service initialization failed: $e');
      // Continue without FCM - app should still work
    }

    // Get FCM token (non-critical)
    try {
      String? fcmToken = await FCMService.getToken();
      debugPrint('[MAIN] FCM Token: $fcmToken');
    } catch (e) {
      debugPrint('[MAIN] Failed to get FCM token: $e');
    }
    
    // Disable app rotation (lock to portrait)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    debugPrint('[MAIN] Starting app...');
    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('[MAIN] Critical error during initialization: $e');
    debugPrint('[MAIN] Stack trace: $stackTrace');
    
    // Show error screen instead of white screen
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('App initialization failed'),
              SizedBox(height: 8),
              Text('Error: $e', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Talkliner',
      debugShowCheckedModeBanner: false,
      translations: AppLanguage(),
      locale: const Locale('en', 'US'),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: Routes.splash,
      getPages: Pages.pages,
      initialBinding: AppBindings(),
    );
  }
}
