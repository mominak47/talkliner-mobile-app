import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';

void main() async {
  final url = 'https://api.talkliner.com/api/domains/status';
  debugPrint('Testing connectivity to: $url');

  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 10);

  try {
    final request = await client.getUrl(Uri.parse(url));
    // Add a dummy token to see if we get 401 or connection error
    request.headers.add('Authorization', 'Bearer dummy_token');

    debugPrint('Request sent, waiting for response...');
    final response = await request.close();

    debugPrint('Response status code: ${response.statusCode}');
    debugPrint('Response headers:');
    response.headers.forEach((name, values) {
      debugPrint('$name: $values');
    });

    final body = await response.transform(utf8.decoder).join();
    debugPrint('Response body: $body');
  } catch (e) {
    debugPrint('Error: $e');
  } finally {
    client.close();
  }
}
