import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../utils/network_checker.dart';
import '../reponse/login_response.dart';
import 'package:music_player_application/utils/constants.dart';
import 'package:music_player_application/service/token_storage.dart';

class AuthRepository {
  final String baseUrl = '${AppConstants.baseUrl}/api/auth';

  Future<LoginResponse> login(String username, String password) async {
    final uri = Uri.parse('$baseUrl/login');

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 1));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(json);

        // Lưu thông tin user
        await TokenStorage.saveToken(loginResponse.token);
        await TokenStorage.saveRole(loginResponse.role);
        await TokenStorage.saveUserId(loginResponse.userId);
        await TokenStorage.saveUsername(loginResponse.username);

        return loginResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Sai tài khoản hoặc mật khẩu');
      } else {
        throw Exception('Lỗi kết nối tới máy chủ! Vui lòng thử lại.');
      }
    } on SocketException {
      final hasNet = await NetworkChecker.hasInternet();
      if (hasNet) {
        throw Exception('Lỗi kết nối tới máy chủ! Vui lòng thử lại.');
      } else {
        throw Exception('Không có kết nối mạng! Vui lòng kiểm tra lại.');
      }
    } on TimeoutException {
      throw Exception('Lỗi kết nối tới máy chủ! Vui lòng thử lại.');
    }
  }
}
