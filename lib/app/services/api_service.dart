import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/config/app_config.dart';
import 'package:talkliner/app/cachemanagers/token_manager.dart';

class ApiService extends GetConnect {
  @override
  void onInit() {
    super.onInit();

    httpClient.baseUrl = AppConfig.apiUrl;
    _configureAuthHeader();
  }

  void _configureAuthHeader() {
    try {
      httpClient.addRequestModifier<Object?>((request) async {
        final token = await TokenManager.getToken();
        if (token.isValid) {
          request.headers['Authorization'] = 'Bearer ${token.token}';
        } else {
          request.headers.remove('Authorization');
        }
        return request;
      });
    } catch (e) {
      debugPrint('Error configuring auth header: $e');
    }
  }

  // Custom GET request method with logging
  Future<Response<T>> makeGetRequest<T>(String url) async {
    debugPrint("GET Request: ${AppConfig.apiUrl}$url");
    return super.get(url);
  }

  Future<Response<T>> makePostRequest<T>(String url, dynamic body) async {
    debugPrint("POST Request: ${AppConfig.apiUrl}$url");
    return super.post(url, body);
  }
}
