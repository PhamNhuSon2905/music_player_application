import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/utils/api_client.dart';

abstract interface class DataSource {
  Future<List<Song>?> loadData();
}

class RemoteDataSource implements DataSource {
  final ApiClient _client;

  RemoteDataSource(BuildContext context) : _client = ApiClient(context);

  @override
  // load danh sách bài hát
  Future<List<Song>?> loadData() async {
    try {
      final response = await _client.get('/api/songs');

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final jsonMap = jsonDecode(body) as Map<String, dynamic>;

        final songList = jsonMap['songs'] as List;
        final songs = songList.map((song) => Song.fromJson(song)).toList();

        songs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return songs;
      } else {
        print('Lỗi lấy danh sách bài hát: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception khi loadData: $e');
      return null;
    }
  }

  // lấy bài hát theo id
  Future<Song?> getSongById(String id) async {
    try {
      final response = await _client.get('/api/songs/$id');

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final json = jsonDecode(body) as Map<String, dynamic>;
        return Song.fromJson(json);
      } else {
        print("Không tìm thấy bài hát (id: $id): ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print('Exception khi getSongById: $e');
      return null;
    }
  }

  // tìm kiếm bài hát
  Future<List<Song>> searchSongs(String keyword) async {
    try {
      final response = await _client.get(
        '/api/songs/search',
        params: {'keyword': keyword},
      );

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final jsonMap = jsonDecode(body) as Map<String, dynamic>;
        final songList = jsonMap['songs'] as List;
        return songList.map((e) => Song.fromJson(e)).toList();
      } else {
        print("Lỗi tìm kiếm bài hát '$keyword': ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print('Exception khi searchSongs: $e');
      return [];
    }
  }
}
