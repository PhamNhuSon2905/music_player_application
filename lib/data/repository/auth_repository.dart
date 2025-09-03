import 'dart:convert';
import 'package:http/http.dart' as http;
import '../reponse/login_response.dart';
import 'package:music_player_application/utils/constants.dart';


class AuthRepository {


  final String baseUrl = '${AppConstants.baseUrl}/api/auth';





  Future<LoginResponse> login(String username, String password) async {
    final uri = Uri.parse('$baseUrl/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return LoginResponse.fromJson(json);
    } else {
      throw Exception('Đăng nhập thất bại: ${response.body}');
    }
  }

  Future<String> register(Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Đăng ký thất bại: ${response.body}');
    }
  }
}
