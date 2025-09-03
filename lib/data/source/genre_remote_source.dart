import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/genre.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/utils/api_client.dart';

class GenreRemoteDataSource {
  final ApiClient _client;

  GenreRemoteDataSource(BuildContext context) : _client = ApiClient(context);

  Future<List<Genre>> fetchAllGenres() async {
    try {
      final response = await _client.get('/api/genres');

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final jsonList = jsonDecode(body) as List;

        return jsonList.map((e) => Genre.fromJson(e)).toList();
      } else {
        print('Lỗi lấy danh sách thể loại: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception khi fetchAllGenres: $e');
      return [];
    }
  }

  Future<List<Song>> fetchSongsByGenreId(int genreId) async {
    try {
      final response = await _client.get('/api/genres/$genreId/songs');

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final jsonList = jsonDecode(body) as List;

        return jsonList.map((e) => Song.fromJson(e)).toList();
      } else {
        print('Lỗi lấy bài hát theo thể loại: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception khi fetchSongsByGenreId: $e');
      return [];
    }
  }
}
