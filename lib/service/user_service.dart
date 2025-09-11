import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_player_application/data/model/user.dart';
import 'package:music_player_application/service/token_storage.dart';
import 'package:music_player_application/utils/api_client.dart';
import 'package:mime/mime.dart';

class UserService {
  final ApiClient _client;
  final BuildContext context;

  UserService(this.context) : _client = ApiClient(context);

  Future<User?> getCurrentUser() async {
    try {
      final response = await _client.get('/api/user/profile');
      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        return User.fromJson(json);
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy thông tin người dùng: $e');
    }
    return null;
  }

  Future<bool> uploadAvatar(File imageFile) async {
    try {
      final mimeType = lookupMimeType(imageFile.path);
      final ext = imageFile.path.split('.').last.toLowerCase();

      final response = await _client.uploadFile(
        '/api/user/avatar',
        file: imageFile, // nếu ApiClient mới
      );


      if (response.statusCode == 200) {
        // Thành công
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 6),
                  Expanded(child: Text('Ảnh đại diện đã được cập nhật thành công!')),
                ],
              ),
            ),
          );
        }
        return true;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ' Tải ảnh thất bại.\n'
                        'Định dạng .$ext (MIME: $mimeType)\n'
                        'Lý do có thể: ảnh quá lớn, không hợp lệ hoặc server từ chối.',
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return false;
    } catch (e) {
      debugPrint('Lỗi upload avatar: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Expanded(child: Text("Đã xảy ra lỗi không xác định khi tải ảnh đại diện!")),
              ],
            ),
          ),
        );
      }
      return false;
    }
  }

  Future<bool> updateProfile(User updatedUser) async {
    try {
      final response = await _client.put(
        '/api/user/profile',
        body: updatedUser.toJson(),
      );

      if (response.statusCode == 200) return true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cập nhật thất bại: ${response.body}")),
      );
      return false;
    } catch (e) {
      debugPrint("Lỗi cập nhật profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xảy ra lỗi khi cập nhật")),
      );
      return false;
    }
  }


  Future<bool> logout() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy token, vui lòng đăng nhập lại!')),
          );
        }
        return false;
      }

      final response = await _client.post('/api/user/logout');

      if (response.statusCode == 200 || response.statusCode == 204) {
        await TokenStorage.clearAll(); // Xóa token & role sau khi logout thành công
        return true;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đăng xuất thất bại: ${response.body}')),
          );
        }
        return false;
      }
    } catch (e) {
      debugPrint('Lỗi logout: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi kết nối khi đăng xuất')),
        );
      }
      return false;
    }
  }




}
