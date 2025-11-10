import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/models/user_model.dart';
import 'package:talkliner/app/services/api_service.dart';

class AuthService extends ApiService {
  Future<String> login(String username, String password) async {
    final trimmedUsername = username.trim();
    final trimmedPassword = password;

    try {
      final response = await post(
        '/domains/login',
        {
          'username': trimmedUsername,
          'password': trimmedPassword,
        },
      );

      if (response.isOk) {
        final token = response.body?['token'];
        if (token is String && token.isNotEmpty) {
          return token;
        }
        throw const FormatException('Malformed login response: token missing');
      }

      throw _mapToAuthException(response);
    } on TimeoutException {
      throw const AuthException('Login request timed out', HttpStatus.requestTimeout);
    } on AuthException {
      rethrow;
    } on FormatException catch (e) {
      throw AuthException(e.message, HttpStatus.internalServerError);
    } catch (e) {
      throw AuthException(e.toString(), HttpStatus.internalServerError);
    }
  }

  Future<UserModel> getUser() async {
    try {
      final response = await get('/domains/status');

      if (response.isOk) {
        final body = response.body;
        final rawUser = body?['data']?['user'];
        if (rawUser is Map<String, dynamic>) {
          return UserModel.fromJson(rawUser);
        }
        throw const FormatException('Malformed user response payload');
      }

      if (response.statusCode == HttpStatus.unauthorized) {
        throw const AuthException.unauthorized();
      }

      throw _mapToAuthException(response);
    } on TimeoutException {
      throw const AuthException('User status request timed out', HttpStatus.requestTimeout);
    } on AuthException {
      rethrow;
    } on FormatException catch (e) {
      throw AuthException(e.message, HttpStatus.internalServerError);
    } catch (e) {
      debugPrint('AuthService: Error getting user: $e');
      throw AuthException(e.toString(), HttpStatus.internalServerError);
    }
  }

  AuthException _mapToAuthException(Response response) {
    final statusCode = response.statusCode ?? 0;
    final message = _extractErrorMessage(response);

    if (statusCode == HttpStatus.unauthorized) {
      return AuthException(message ?? 'Invalid credentials', statusCode);
    }

    return AuthException(message ?? 'Login failed', statusCode);
  }

  String? _extractErrorMessage(Response response) {
    final body = response.body;
    if (body is Map<String, dynamic>) {
      final data = body['message'] ?? body['error'] ?? body['detail'];
      if (data is String && data.isNotEmpty) {
        return data;
      }
    } else if (body is String && body.isNotEmpty) {
      return body;
    }
    return response.statusText;
  }
}

class AuthException implements Exception {
  final String message;
  final int statusCode;

  const AuthException(this.message, this.statusCode);

  const AuthException.unauthorized()
      : message = 'Unauthorized',
        statusCode = HttpStatus.unauthorized;

  @override
  String toString() => 'AuthException($statusCode): $message';
}
