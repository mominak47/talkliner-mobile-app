import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/controllers/auth_controller.dart';
import 'package:talkliner/app/views/profile/parts/user_settins_profile.dart';
import 'package:talkliner/app/views/profile/parts/user_settings_main.dart';
import 'package:talkliner/app/views/profile/parts/user_settings_status.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});


  @override
  Widget build(BuildContext context) {
  final AuthController authController = Get.find<AuthController>();
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
              UserSettingsProfile(),
              SizedBox(height: 16),
              UserSettingsStatus(),
              SizedBox(height: 16),
              UserSettingsMain(),
              SizedBox(height: 16),
              ElevatedButton(onPressed: () => authController.logout(), child: const Text('Logout')),
            ],
          ),
        ),
      )
    );
  }
}