import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/config/routes.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final GetStorage _storage = GetStorage();

  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final Rxn<String> _token = Rxn<String>();

  final Rxn<UserModel> user = Rxn<UserModel>();

  String get token => _token.value ?? '';

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void login(String username, String password) async {
    isLoading.value = true;
    try {
      _token.value = await authService.login(username, password);
      // Persist the token in storage
      _storage.write('authToken', _token.value);
      isLoggedIn.value = true;

      user.value = await authService.getUser();

      Get.offAllNamed(Routes.home);
    } catch (e) {
      debugPrint(e.toString());
      isLoggedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void loginWithToken(String token) async {
    _token.value = token;
    _storage.write('authToken', _token.value);
    isLoggedIn.value = true;
    Get.offAllNamed(Routes.home);
  }

  // Checks if a token exists in storage to determine the login state.
  void _checkLoginStatus() async {
    try {
      final storedToken = _storage.read('authToken');
      if (storedToken != null) {
        _token.value = storedToken;
        isLoggedIn.value = true;
        user.value = await authService.getUser();
      }
    } catch (e) {
      debugPrint(e.toString());

      // Delete the token from storage
      _storage.remove('authToken');

      // Take user to login screen
      Get.offAllNamed(Routes.login);
    }

    debugPrint('Login status: ${isLoggedIn.value}');
  }

  void logout() {
    _storage.remove('authToken');
    isLoggedIn.value = false;

    // Clear GetStorage All
    _storage.erase();

    Get.offAllNamed(Routes.login);
  }
}
