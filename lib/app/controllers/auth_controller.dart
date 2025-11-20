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
      _token.value = issuedToken.token;

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
    
    // Save token to storage with a far future expiry since QR tokens are pre-validated
    // 7 days in milliseconds
    final validUntil = DateTime.now().millisecondsSinceEpoch + (7 * 24 * 60 * 60 * 1000);
    await TokenManager.setToken(TokenModel(token: _token.value!, validUntil: validUntil));
    
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

  void fetchUser() async {
    try {
      user.value = await authService.getUser();
    } on AuthException catch (e) {
      error.value = e.message;
      isLoggedIn.value = false;
    } catch (e) {
      error.value = 'Unexpected error occurred. Please try again.';
      debugPrint('Fetch user error: $e');
    }
  }

  // Checks if a token exists in storage to determine the login state.
  void _checkLoginStatus() async {
    try {
      debugPrint('Checking login status');
      TokenModel storedToken = await TokenManager.getToken();
      debugPrint('STORED Token: ${storedToken.toJson()}');
      
      if (storedToken.isValid) {
        debugPrint('Valid token found');
        // _token.value = storedToken.token;
        try {
          fetchUser();
          isLoggedIn.value = true;
          debugPrint('User logged in');

        } on AuthException catch (e) {
          debugPrint('Token invalid or expired: ${e.message}');
          error.value = e.message;
          isLoggedIn.value = false;
          // await TokenManager.removeToken();
          // await Get.offAllNamed(Routes.login);
        }
      } else {
        debugPrint('No valid token found');
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
      // Delete the token from storage if there was an error
      await TokenManager.removeToken();
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
