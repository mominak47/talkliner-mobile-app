import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';

class TokenManager {
  static const String tokenKey = 'authToken';
  static final GetStorage _storage = GetStorage();

  static Future<TokenModel> getToken() async {
    final storedData = _storage.read(tokenKey);
    if (storedData != null) {
      if (storedData is Map<String, dynamic>) {
        return TokenModel.fromJson(storedData);
      } else if (storedData is String) {
        try {
          // Try parsing as JSON string just in case
          return TokenModel.fromJson(jsonDecode(storedData));
        } catch (e) {
          debugPrint('Error decoding token string: $e');
        }
      }
    }
    return TokenModel(token: '', validUntil: 0);
  }

  static Future<void> setToken(TokenModel token) async {
    if (!token.isValid) {
      await removeToken();
      return;
    }
    await _storage.write(tokenKey, token.toJson());
    debugPrint('Token saved to GetStorage');
  }

  static Future<void> removeToken() async {
    await _storage.remove(tokenKey);
    debugPrint('Token removed from GetStorage');
  }

  static Future<bool> hasToken() async {
    return _storage.hasData(tokenKey);
  }
}

class TokenModel {
  final String token;
  final int validUntil;

  TokenModel({
    required this.token,
    required this.validUntil,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(token: json['token'], validUntil: json['valid_until']);
  }

  int getCurrentTimestamp() {
    // Return timestamp in milliseconds since epoch (most common format)
    return DateTime.now().millisecondsSinceEpoch;
  }

  bool get isValid => token.isNotEmpty && validUntil > getCurrentTimestamp();

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'valid_until': validUntil,
    };
  }
}