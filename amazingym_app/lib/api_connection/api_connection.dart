import 'package:dio/dio.dart';

class ApiConnection {
  static const String baseUrl = 'http://157.230.40.203:8080/gym-face-id-access/api/auth';
  final Dio _dio = Dio();

  ApiConnection() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<String?> login(String username, String password) async {
    try {
      Response response = await _dio.post('/login', data: {
        "username": username,
        "password": password
      });

      if (response.statusCode == 200 && response.data["success"] == true) {
        String token = response.data["data"]; // JWT Token
        print('Login Successful! Token: $token');
        return token; // Return the token to be stored
      } else {
        print('Login failed: ${response.data["message"]}');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
}
