import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/utils/api_client.dart';

import '../reponse/playlist_song_reponse.dart';

class PlaylistSongRemoteDataSource {
  final ApiClient _client;

  PlaylistSongRemoteDataSource(BuildContext context)
    : _client = ApiClient(context);

  // Lấy danh sách bài hát trong playlist
  Future<List<Song>> fetchSongsByPlaylist(int playlistId) async {
    try {
      final response = await _client.get('/api/playlist-songs/$playlistId');

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final jsonMap = jsonDecode(body) as Map<String, dynamic>;
        final jsonList = jsonMap['songs'] as List;

        return jsonList
            .map((e) => PlaylistSongResponse.fromJson(e).toSong())
            .toList();
      } else {
        debugPrint("Lỗi lấy bài hát trong playlist: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Exception fetchSongsByPlaylist: $e");
      return [];
    }
  }

  // Thêm bài hát vào playlist
  Future<void> addSongToPlaylist(int playlistId, String songId) async {
    try {
      final response = await _client.post(
        '/api/playlist-songs',
        body: {"playlistId": playlistId, "songId": songId},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Thêm bài hát thất bại: ${response.body}");
      }
    } catch (e) {
      throw Exception("Exception addSongToPlaylist: $e");
    }
  }

  // Xóa bài hát khỏi playlist
  Future<void> removeSongFromPlaylist(int playlistId, String songId) async {
    try {
      final response = await _client.delete(
        '/api/playlist-songs/$playlistId/$songId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception("Xóa bài hát khỏi playlist thất bại: ${response.body}");
      }
    } catch (e) {
      throw Exception("Exception removeSongFromPlaylist: $e");
    }
  }
}
