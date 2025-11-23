import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/config/app_config.dart';
import 'package:talkliner/app/cachemanagers/token_manager.dart';

class ApiService extends GetConnect {
  @override
  void onInit() {
    super.onInit();
    updateBaseUrl(AppConfig.apiUrl);
    _configureRequestInterceptor();
    _configureResponseInterceptor();
  }

  // Update base URL dynamically
  void updateBaseUrl(String newUrl) {
    httpClient.baseUrl = newUrl;
    debugPrint('[ApiService] Base URL updated to: $newUrl');
  }

  // Configure request interceptor (runs once, applies to all requests)
  void _configureRequestInterceptor() {
    try {
      httpClient.addRequestModifier<Object?>((request) async {
        // Add authentication token
        final token = await TokenManager.getToken();
        if (token.isValid) {
          request.headers['Authorization'] = 'Bearer ${token.token}';
          if (kDebugMode) {
            debugPrint('[ApiService] Request: ${request.method} ${request.url}');
            debugPrint('[ApiService] Auth token added');
          }
        } else {
          request.headers.remove('Authorization');
          if (kDebugMode) {
            debugPrint('[ApiService] Request: ${request.method} ${request.url} (no token)');
          }
        }
        
        // Add common headers
        request.headers['Content-Type'] = 'application/json';
        request.headers['Accept'] = 'application/json';
        
        return request;
      });
    } catch (e) {
      debugPrint('[ApiService] Error configuring request interceptor: $e');
    }
  }

  // Configure response interceptor for global error handling
  void _configureResponseInterceptor() {
    httpClient.addResponseModifier((request, response) async {
      if (kDebugMode) {
        debugPrint('[ApiService] Response: ${response.statusCode} for ${request.url}');
      }

      // Handle 401 Unauthorized globally
      if (response.statusCode == 401) {
        debugPrint('[ApiService] 401 Unauthorized - Token expired or invalid');
        // Remove invalid token
        await TokenManager.removeToken();
        // Note: AuthController will handle navigation via _checkLoginStatus
      }

      // Log errors in debug mode
      if (response.hasError && kDebugMode) {
        debugPrint('[ApiService] Error ${response.statusCode}: ${response.statusText}');
        debugPrint('[ApiService] Body: ${response.body}');
        if(response.statusCode == 401) {
          // Logout
          debugPrint('[ApiService] 401 Unauthorized - Logging out');
        }
      }

      return response;
    });
  }

  // Simplified GET request with timeout
  Future<Response<T>> makeGetRequest<T>(String url) async {
    try {
      return await get<T>(url).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          return Response(
            statusCode: 408,
            statusText: 'Request timeout',
          );
        },
      );
    } catch (e) {
      debugPrint('[ApiService] GET error for $url: $e');
      rethrow;
    }
  }

  // Simplified POST request with timeout
  Future<Response<T>> makePostRequest<T>(String url, dynamic body) async {
    try {
      return await post<T>(url, body).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          return Response(
            statusCode: 408,
            statusText: 'Request timeout',
          );
        },
      );
    } catch (e) {
      debugPrint('[ApiService] POST error for $url: $e');
      rethrow;
    }
  }
}
