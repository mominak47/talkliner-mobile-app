import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:talkliner/app/cachemanagers/token_manager.dart';
import 'package:talkliner/app/config/app_config.dart';

class TalklinerService {
  // static Map<String, String> headers = {
  //   'Content-Type': 'application/json',
  //   'Accept': 'application/json',
  // };

  // Static function to get headers
  static Future<Map<String, dynamic>> getConfig() async {
    TokenModel token = await TokenManager.getToken();
    String apiUrl = AppConfig().apiUrl();

    debugPrint("Token : ${token.toJson()}");
    return {
      'headers': {
        'Authorization': 'Bearer ${token.token}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      'base_url': apiUrl,
    };
  }

  static Future<http.Response> get(String url) async {
    var config = await getConfig();
    debugPrint("Headers : ${config.toString()}");

    // Bind BASE_URL
    url = "${config['base_url']}${url}";

    // URL
    debugPrint("URL : $url");

    final headers = Map<String, String>.from(config['headers']);
    return http.get(Uri.parse(url), headers: headers);
  }

  static Future<http.Response> post(String url, {body}) async {
    var config = await getConfig();

    // Bind BASE_URL
    url = "${config['base_url']}${url}";

    // URL
    debugPrint("URL : $url");

    // Body
    debugPrint("Body : ${body.toString()}");

    final headers = Map<String, String>.from(config['headers']);
    debugPrint("Headers: $headers");

    return http.post(Uri.parse(url), body: jsonEncode(body), headers: headers);
  }

  static Future<http.Response> put(String url, {body}) async {
    return await http.put(Uri.parse(url), body: body);
  }

  static Future<http.Response> delete(String url) async {
    return await http.delete(Uri.parse(url));
  }
}
