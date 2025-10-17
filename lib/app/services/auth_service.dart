import 'package:flutter/material.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/services/api_service.dart';

class AuthService extends ApiService {
  Future<String> login(String username, String password) async {
    final response = await post('/domains/login', {
      'username': username,
      'password': password,
    });

    if (response.statusCode == 200 && response.body['token'] != null) {
      return response.body['token'];
    }

    return throw Exception(response.body);
  }

  Future<UserModel> getUser() async {
    try {
      onInit();
      final response = await get('/domains/status');

      if (response.statusCode == 200) {
        final UserModel user = UserModel.fromJson(
          response.body['data']['user'],
        );
        return user;
      } else {
        return throw Exception(response.body);
      }
    } catch (e) {
      debugPrint('AuthService: Error getting user: $e');
      return throw Exception(e);
    }
  }
}
