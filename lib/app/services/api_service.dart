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
    httpClient.addRequestModifier<Object?>((request) async {
      final token = await TokenManager.getToken();
      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      } else {
        request.headers.remove('Authorization');
      }
      return request;
    });
  }

}
