import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/playlist.dart';
import 'package:music_player_application/utils/api_client.dart';

class PlaylistRemoteDataSource {
  final ApiClient _client;

  PlaylistRemoteDataSource(BuildContext context) : _client = ApiClient(context);

  /// Lấy danh sách playlist theo userId
  Future<List<Playlist>> fetchPlaylistsByUser(int userId) async {
    try {
      final response = await _client.get('/api/playlists/user/$userId');

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final jsonMap = jsonDecode(body) as Map<String, dynamic>;
        final jsonList = jsonMap['playlists'] as List;
        return jsonList.map((e) => Playlist.fromJson(e)).toList();
      } else {
        debugPrint("❌ Lỗi lấy playlists: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Exception fetchPlaylistsByUser: $e");
      return [];
    }
  }

  /// Tạo playlist mới (có hoặc không có ảnh)
  Future<Playlist> createPlaylist(String name, String? imagePath, int userId) async {
    try {
      if (imagePath != null && imagePath.isNotEmpty) {
        // ✅ Có ảnh → multipart/form-data
        final response = await _client.uploadFile(
          '/api/playlists',
          file: File(imagePath),
          fields: {
            'name': name,
            'userId': userId.toString(),
          },
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final body = utf8.decode(response.bodyBytes);
          final json = jsonDecode(body);
          return Playlist.fromJson(json['playlist']);
        } else {
          throw Exception("❌ Tạo playlist thất bại: ${response.body}");
        }
      } else {

        final response = await _client.post(
          '/api/playlists',
          body: {"name": name, "userId": userId},
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final body = utf8.decode(response.bodyBytes);
          final json = jsonDecode(body);
          return Playlist.fromJson(json['playlist']);
        } else {
          throw Exception("❌ Tạo playlist thất bại: ${response.body}");
        }
      }
    } catch (e) {
      throw Exception("❌ Exception createPlaylist: $e");
    }
  }

  /// Xóa playlist theo ID
  Future<void> deletePlaylist(int playlistId) async {
    try {
      final response = await _client.delete('/api/playlists/$playlistId');

      if (response.statusCode != 200) {
        throw Exception("❌ Xóa playlist thất bại: ${response.body}");
      }
    } catch (e) {
      throw Exception("❌ Exception deletePlaylist: $e");
    }
  }
}
