import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:talkliner/app/config/app_config.dart';

class ApiService extends GetConnect {
  @override
  void onInit() {
    super.onInit();

    httpClient.baseUrl = AppConfig.apiUrl;

    try {
      String token = GetStorage().read('authToken');
      debugPrint('ApiService onInit with token: $token');
      if (token.isNotEmpty) {
        httpClient.addRequestModifier<Object?>((request) {
          request.headers['Authorization'] = 'Bearer $token';
          return request;
        });
      }
    } catch (e) {
      debugPrint('ApiService onInit error: $e');
    }
  }
  
}
