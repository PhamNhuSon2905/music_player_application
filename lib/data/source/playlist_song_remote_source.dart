import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/playlist_song.dart';
import 'package:music_player_application/utils/api_client.dart';

class PlaylistSongRemoteDataSource {
  final ApiClient _client;

  PlaylistSongRemoteDataSource(BuildContext context) : _client = ApiClient(context);

  /// Lấy danh sách bài hát trong playlist
  Future<List<PlaylistSong>> fetchSongsByPlaylist(int playlistId) async {
    try {
      final response = await _client.get('/api/playlists/$playlistId/songs');

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final jsonList = jsonDecode(body) as List;
        return jsonList.map((e) => PlaylistSong.fromJson(e)).toList();
      } else {
        debugPrint("❌ Lỗi lấy bài hát trong playlist: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Exception fetchSongsByPlaylist: $e");
      return [];
    }
  }

  /// Thêm bài hát vào playlist
  Future<void> addSongToPlaylist(int playlistId, String songId) async {
    try {
      final response = await _client.post(
        '/api/playlist-songs',
        body: {
          "playlistId": playlistId,
          "songId": songId,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("❌ Thêm bài hát thất bại: ${response.body}");
      }
    } catch (e) {
      throw Exception("❌ Exception addSongToPlaylist: $e");
    }
  }

  /// Xóa bài hát khỏi playlist
  Future<void> removeSongFromPlaylist(int playlistSongId) async {
    try {
      final response = await _client.delete('/api/playlist-songs/$playlistSongId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception("❌ Xóa bài hát khỏi playlist thất bại: ${response.body}");
      }
    } catch (e) {
      throw Exception("❌ Exception removeSongFromPlaylist: $e");
    }
  }
}
