import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amazingym_app/api_connection/sse_service.dart';

class API {
  static const hostConnect =
      "http://157.230.40.203:8080/gym-face-id-access/api/v1";
  static String? authToken;
  static SSEService? sseService;

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
      initializeSSE();
    } else {
      print(
          'Failed to login, status code: ${response.statusCode}, body: ${utf8.decode(response.bodyBytes)}');
      throw Exception('Failed to login');
    }
  }

  // Initialize SSE service
  static void initializeSSE() {
    sseService = SSEService(
      '$hostConnect/customer/subscribe',
      {'Authorization': 'Bearer ${authToken}'},
    );
    sseService!.startListening();
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
      print(
          'Access forbidden, status code: ${response.statusCode}, body: ${utf8.decode(response.bodyBytes)}');
    }

    return response;
  }

  // POST request with token
  static Future<http.Response> postRequest(String endpoint, Map<String, dynamic> body) async {
  if (authToken == null) {
    throw Exception('Auth token is null. Please login first.');
  }

  final response = await http.post(
    Uri.parse('$hostConnect/$endpoint'),
    headers: {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );

  if (response.statusCode == 403) {
    print(
        'Access forbidden, status code: ${response.statusCode}, body: ${utf8.decode(response.bodyBytes)}');
  }

  return response;
}
}
