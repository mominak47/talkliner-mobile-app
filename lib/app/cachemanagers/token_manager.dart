import 'package:get_storage/get_storage.dart';

class TokenManager {
  static const String tokenKey = 'authToken';

  static Future<String> getToken() async {
    return GetStorage().read(tokenKey) ?? '';
  }

  static Future<void> setToken(String token) async {
    if (token.isNotEmpty) {
      await GetStorage().write(tokenKey, token);
    }
  }

  static Future<void> removeToken() async {
    await GetStorage().remove(tokenKey);
  }

  static Future<bool> hasToken() async {
    return GetStorage().hasData(tokenKey);
  }
}