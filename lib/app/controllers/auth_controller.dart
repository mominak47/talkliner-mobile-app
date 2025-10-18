import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/config/routes.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/services/auth_service.dart';
import 'package:talkliner/app/cachemanagers/token_manager.dart';

class AuthController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final GetStorage _storage = GetStorage();

  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final Rxn<String> _token = Rxn<String>();

  final Rxn<UserModel> user = Rxn<UserModel>();

  // Error
  final Rxn<String> error = Rxn<String>();

  String get token => _token.value ?? '';


  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void login(String username, String password) async {
    isLoading.value = true;
    error.value = null;
    try {
      _token.value = await authService.login(username, password);
      // Persist the token in storage
      await TokenManager.setToken(_token.value ?? '');
      isLoggedIn.value = true;

      user.value = await authService.getUser();
      Get.offAllNamed(Routes.home);
    } catch (e) {
      // Get Error Message
      error.value = e.toString().split('message:')[1].trim().replaceAll('}', '');
      
      debugPrint("Login error: ${error.value}");
      isLoggedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void loginWithToken(String token) async {
    _token.value = token;
    await TokenManager.setToken(_token.value ?? '');
    debugPrint("TOKEN: ${_token.value}");
    // isLoggedIn.value = true;
    // user.value = await authService.getUser();
    // Get.offAllNamed(Routes.home);
  }

  // Checks if a token exists in storage to determine the login state.
  void _checkLoginStatus() async {
    try {
      final storedToken = await TokenManager.getToken();
      if (storedToken.isNotEmpty) {
        _token.value = storedToken;
        isLoggedIn.value = true;
        user.value = await authService.getUser();
      }
    } catch (e) {
      debugPrint(e.toString());

      // Delete the token from storage
      await TokenManager.removeToken();

      // Take user to login screen
      Get.offAllNamed(Routes.login);
    }

    debugPrint('Login status: ${isLoggedIn.value}');
  }

  void logout() async {
    await TokenManager.removeToken();
    isLoggedIn.value = false;

    // Clear GetStorage All
    await GetStorage().erase();

    Get.offAllNamed(Routes.login);
  }
}
