import 'dart:io';
import 'dart:convert';

void main() async {
  final url = 'https://api.talkliner.com/api/domains/status';
  print('Testing connectivity to: $url');

  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 10);

  try {
    final request = await client.getUrl(Uri.parse(url));
    // Add a dummy token to see if we get 401 or connection error
    request.headers.add('Authorization', 'Bearer dummy_token');

    print('Request sent, waiting for response...');
    final response = await request.close();

    print('Response status code: ${response.statusCode}');
    print('Response headers:');
    response.headers.forEach((name, values) {
      print('$name: $values');
    });

    final body = await response.transform(utf8.decoder).join();
    print('Response body: $body');
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
