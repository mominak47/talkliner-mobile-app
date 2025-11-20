import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';
import 'package:talkliner/app/views/profile/parts/user_settins_profile.dart';
import 'package:talkliner/app/views/profile/parts/user_settings_main.dart';
import 'package:talkliner/app/views/profile/parts/user_settings_status.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});


  @override
  Widget build(BuildContext context) {
  final AuthController authController = Get.find<AuthController>();
  final token = GetStorage().read('authToken');
  // Format in x days left
  final daysLeft = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(token['valid_until'])).inDays;
  final daysLeftString = daysLeft.abs().toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16), 
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(() => UserSettingsProfile()),
              SizedBox(height: 16),
              UserSettingsStatus(),
              SizedBox(height: 16),
              UserSettingsMain(),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => authController.logout(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: TalklinerThemeColors.primary500,
                    foregroundColor: Colors.red,
                    elevation: 0,
                  ),
                  child: Text('Logout'.tr),
                ),
              ),
              SizedBox(height: 16),
              Text('Version'.tr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text('1.0.0', style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal)),
              // Show the valid until date of the token
              Text('Token valid until: ${daysLeftString} days left'), // Format the date to be more readable
            ],
          ),
        ),
      )
    );
  }
}