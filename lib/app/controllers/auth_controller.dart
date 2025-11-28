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

  Future<void> login(String username, String password) async {
    // Prevent multiple simultaneous login attempts
    if (isLoading.value) {
      debugPrint('[AuthController] Login already in progress');
      return;
    }

    if (!_canAttemptLogin()) {
      debugPrint('[AuthController] Rate limit: Too many login attempts');
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
      debugPrint('[AuthController] Attempting login for: $sanitizedUsername');
      final issuedToken = await authService.login(
        sanitizedUsername,
        sanitizedPassword,
      );
      _token.value = issuedToken.token;

      debugPrint('[AuthController] Token received, fetching user');
      user.value = await authService.getUser();

      isLoggedIn.value = true;
      debugPrint('[AuthController] Login successful');

      await Get.offAllNamed(Routes.home);
    } on AuthException catch (e) {
      error.value = e.message;
      isLoggedIn.value = false;
      await TokenManager.removeToken();
      debugPrint('[AuthController] Login failed: ${e.message}');
    } catch (e) {
      error.value = 'Unexpected error occurred. Please try again.';
      isLoggedIn.value = false;
      await TokenManager.removeToken();
      debugPrint('[AuthController] Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithToken(String token) async {
    if (token.isEmpty) {
      error.value = 'Invalid token.';
      return;
    }

    if (isLoading.value) {
      debugPrint('[AuthController] Login with token already in progress');
      return;
    }

    isLoading.value = true;
    error.value = null;

    _token.value = token.trim();

    // Save token to storage with a far future expiry since QR tokens are pre-validated
    // 7 days in milliseconds
    final validUntil =
        DateTime.now().millisecondsSinceEpoch + (7 * 24 * 60 * 60 * 1000);
    await TokenManager.setToken(
      TokenModel(token: _token.value!, validUntil: validUntil),
    );

    try {
      debugPrint('[AuthController] Logging in with token');
      user.value = await authService.getUser();
      isLoggedIn.value = true;
      debugPrint('[AuthController] Token login successful');
      await Get.offAllNamed(Routes.home);
    } on AuthException catch (e) {
      error.value = e.message;
      isLoggedIn.value = false;
      await TokenManager.removeToken();
      debugPrint('[AuthController] Token login failed: ${e.message}');
    } catch (e) {
      error.value = 'Unexpected error occurred. Please try again.';
      isLoggedIn.value = false;
      await TokenManager.removeToken();
      debugPrint('[AuthController] Token login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUser() async {
    try {
      user.value = await authService.getUser();
      debugPrint('[AuthController] User fetched successfully');
    } on AuthException catch (e) {
      error.value = e.message;
      isLoggedIn.value = false;
      await TokenManager.removeToken();
      debugPrint('[AuthController] Auth error fetching user: ${e.message}');
      rethrow; // Re-throw to be caught by caller
    } catch (e) {
      error.value = 'Unexpected error occurred. Please try again.';
      debugPrint('[AuthController] Fetch user error: $e');
      rethrow;
    }
  }

  // Checks if a token exists in storage to determine the login state.
  Future<void> _checkLoginStatus() async {
    try {
      debugPrint('[AuthController] Checking login status');
      TokenModel storedToken = await TokenManager.getToken();
      debugPrint('[AuthController] Stored Token: ${storedToken.toJson()}');
      if (storedToken.token.isNotEmpty) {
        debugPrint(
          '[AuthController] Token length: ${storedToken.token.length}',
        );
      }

      if (storedToken.isValid) {
        debugPrint('[AuthController] Valid token found, fetching user');
        _token.value = storedToken.token;

        try {
          await fetchUser();
          isLoggedIn.value = true;
          debugPrint('[AuthController] Auto-login successful');
        } on AuthException catch (e) {
          debugPrint('[AuthController] Token invalid or expired: ${e.message}');
          error.value = e.message;
          isLoggedIn.value = false;
          await TokenManager.removeToken();
          // User will be on login screen by default, no need to navigate
        } catch (e) {
          debugPrint('[AuthController] Error during auto-login: $e');
          isLoggedIn.value = false;
          await TokenManager.removeToken();
        }
      } else {
        debugPrint('[AuthController] No valid token found');
        isLoggedIn.value = false;
      }
    } catch (e) {
      debugPrint('[AuthController] Error checking login status: $e');
      isLoggedIn.value = false;
      // Delete the token from storage if there was an error
      await TokenManager.removeToken();
    }

    debugPrint('[AuthController] Login status: ${isLoggedIn.value}');
  }

  Future<void> logout() async {
    debugPrint('[AuthController] Logging out');

    await TokenManager.removeToken();
    isLoggedIn.value = false;
    _token.value = null;
    user.value = null;
    error.value = null;

    // Clear GetStorage All
    await GetStorage().erase();

    debugPrint('[AuthController] Logout complete, redirecting to login');
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
