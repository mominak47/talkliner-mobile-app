import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/config/routes.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/services/auth_service.dart';
import 'package:talkliner/app/cachemanagers/token_manager.dart';

class AuthController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final Rxn<String> _token = Rxn<String>();

  final Rxn<UserModel> user = Rxn<UserModel>();

  // Error
  final Rxn<String> error = Rxn<String>();

  DateTime? _lastLoginAttempt;

  String get token => _token.value ?? '';


  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void login(String username, String password) async {
    if (isLoading.value || !_canAttemptLogin()) {
      return;
    }

    final sanitizedUsername = username.trim();
    final sanitizedPassword = password;

    if (sanitizedUsername.isEmpty || sanitizedPassword.isEmpty) {
      error.value = 'Username and password are required.';
      return;
    }

    _lastLoginAttempt = DateTime.now();
    isLoading.value = true;
    error.value = null;
    try {
      final issuedToken = await authService.login(sanitizedUsername, sanitizedPassword);
      _token.value = issuedToken;

      await TokenManager.setToken(issuedToken);
      isLoggedIn.value = true;

      user.value = await authService.getUser();

      await Get.offAllNamed(Routes.home);
    } on AuthException catch (e) {
      error.value = e.message;
      isLoggedIn.value = false;
      await TokenManager.removeToken();
    } catch (e) {
      error.value = 'Unexpected error occurred. Please try again.';
      debugPrint('Login error: $e');
      isLoggedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void loginWithToken(String token) async {
    if (token.isEmpty) {
      error.value = 'Invalid token.';
      return;
    }

    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    error.value = null;

    _token.value = token.trim();
    await TokenManager.setToken(_token.value ?? '');
    try {
      user.value = await authService.getUser();
      isLoggedIn.value = true;
      await Get.offAllNamed(Routes.home);
    } on AuthException catch (e) {
      error.value = e.message;
      isLoggedIn.value = false;
      await TokenManager.removeToken();
    } catch (e) {
      error.value = 'Unexpected error occurred. Please try again.';
      debugPrint('Login with token error: $e');
      isLoggedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Checks if a token exists in storage to determine the login state.
  void _checkLoginStatus() async {
    try {
      final storedToken = await TokenManager.getToken();
      if (storedToken.isNotEmpty) {
        _token.value = storedToken;
        try {
          user.value = await authService.getUser();
          isLoggedIn.value = true;
        } on AuthException catch (e) {
          error.value = e.message;
          isLoggedIn.value = false;
          await TokenManager.removeToken();
          await Get.offAllNamed(Routes.login);
        }
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

  bool _canAttemptLogin() {
    if (_lastLoginAttempt == null) {
      return true;
    }
    final difference = DateTime.now().difference(_lastLoginAttempt!);
    return difference.inMilliseconds > 800;
  }
}
