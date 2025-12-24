import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talkliner/app/config/app_bindings.dart';
import 'package:talkliner/app/config/pages.dart';
import 'package:talkliner/app/config/routes.dart';
import 'package:talkliner/app/language/app_language.dart';
import 'package:talkliner/app/themes/app_theme.dart';
import 'package:talkliner/app/views/calling/widgets/global_call_overlay.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:talkliner/service/background_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:talkliner/app/services/fcm/fcm_service.dart';
import 'firebase_options.dart';
import 'app_lifecycle_controller.dart';

Future<void> main() async {
  Get.put(AppLifecycleController(), permanent: true);

  try {
    // Initialize Flutter bindings
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize PushNotificationService
    await Get.putAsync(() => FcmService().onInitService());

    // Request Notification Permission for Android 13+
    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });

    // Initialize Background Service
    await initializeService();

    // Initialize GetStorage with auto-recovery
    try {
      await GetStorage.init();

      await GetStorage.init("user_cache");

      debugPrint('[MAIN] GetStorage initialized successfully');
    } catch (e) {
      debugPrint('[MAIN] GetStorage initialization failed: $e');
      if (e.toString().contains('FormatException') ||
          e.toString().contains('Unexpected character')) {
        debugPrint(
          '[MAIN] Detected corrupted GetStorage file. Attempting to delete...',
        );
        try {
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/GetStorage.gs');
          if (await file.exists()) {
            await file.delete();
            debugPrint('[MAIN] Corrupted GetStorage file deleted.');
            // Retry initialization
            await GetStorage.init();
            debugPrint(
              '[MAIN] GetStorage re-initialized successfully after cleanup.',
            );
          } else {
            debugPrint('[MAIN] GetStorage file not found at ${file.path}');
          }
        } catch (cleanupError) {
          debugPrint(
            '[MAIN] Failed to clean up corrupted GetStorage: $cleanupError',
          );
        }
      }
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
    runApp(
      GetMaterialApp(
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
      ),
    );
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
      builder: (context, child) {
        return Stack(children: [child!, GlobalCallOverlay()]);
      },
    );
  }
}
