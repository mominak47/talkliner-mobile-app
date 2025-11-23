import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'package:talkliner/app/config/app_bindings.dart';
import 'package:talkliner/app/config/pages.dart';
import 'package:talkliner/app/config/routes.dart';
import 'package:talkliner/app/language/app_language.dart';
import 'package:talkliner/app/themes/app_theme.dart';

Future<void> main() async {
  try {
    // Initialize Flutter bindings
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize GetStorage
    await GetStorage.init();
    debugPrint('[MAIN] GetStorage initialized successfully');
    
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
