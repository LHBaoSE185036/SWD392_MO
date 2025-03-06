import 'dart:convert';
import 'package:http/http.dart' as http;

class API {
  static const hostConnect = "http://157.230.40.203:8080/gym-face-id-access/api";
  static String? authToken;

  // Login method to get the token
  static Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$hostConnect/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      authToken = jsonResponse['data'];
      print('Login successful, token: $authToken');
    } else {
      print('Failed to login, status code: ${response.statusCode}, body: ${utf8.decode(response.bodyBytes)}');
      throw Exception('Failed to login');
    }
  }

  // GET request with token
  static Future<http.Response> getRequest(String endpoint) async {
    if (authToken == null) {
      throw Exception('Auth token is null. Please login first.');
    }

    final response = await http.get(
      Uri.parse('$hostConnect/$endpoint'),
      headers: {'Authorization': 'Bearer ${authToken}'},
    );

    if (response.statusCode == 403) {
      print('Access forbidden, status code: ${response.statusCode}, body: ${utf8.decode(response.bodyBytes)}');
    }

    return response;
  }
}