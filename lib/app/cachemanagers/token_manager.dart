import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

class TokenManager {
  static const String tokenKey = 'authToken';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final GetStorage _fallbackStorage = GetStorage();

  static Future<String> getToken() async {
    if (!kIsWeb) {
      try {
        final secureToken = await _secureStorage.read(key: tokenKey);
        if (secureToken != null && secureToken.isNotEmpty) {
          return secureToken;
        }
      } catch (_) {
        // Ignore and fall back to GetStorage
      }
    }

    return _fallbackStorage.read(tokenKey) ?? '';
  }

  static Future<void> setToken(String token) async {
    if (token.isEmpty) {
      await removeToken();
      return;
    }

    var persisted = false;

    if (!kIsWeb) {
      try {
        await _secureStorage.write(key: tokenKey, value: token);
        persisted = true;
      } catch (_) {
        persisted = false;
      }
    }

    if (!persisted) {
      await _fallbackStorage.write(tokenKey, token);
    }
  }

  static Future<void> removeToken() async {
    if (!kIsWeb) {
      try {
        await _secureStorage.delete(key: tokenKey);
      } catch (_) {
        // Ignore failure and continue to clear fallback storage
      }
    }

    await _fallbackStorage.remove(tokenKey);
  }

  static Future<bool> hasToken() async {
    if (!kIsWeb) {
      try {
        final secureToken = await _secureStorage.read(key: tokenKey);
        if (secureToken != null && secureToken.isNotEmpty) {
          return true;
        }
      } catch (_) {
        // Ignore and fall back
      }
    }

    return _fallbackStorage.hasData(tokenKey);
  }
}