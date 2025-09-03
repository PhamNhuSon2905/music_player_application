import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/favorite_song.dart';

import '../../utils/api_client.dart';

class FavoriteSongRemoteDataSource {
  final ApiClient _apiClient;

  FavoriteSongRemoteDataSource(BuildContext context)
      : _apiClient = ApiClient(context);

  Future<List<FavoriteSong>> fetchFavoritesByUser(int userId) async {
    final response = await _apiClient.get('/api/favorites/$userId');

    print('[Favorite] GET /api/favorites/$userId');
    print('[Favorite] Status Code: ${response.statusCode}');
    print('[Favorite] Body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => FavoriteSong.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load favorite songs: ${response.statusCode} - ${response.body}');
    }
  }


  Future<void> addFavorite(int userId, String songId) async {
    final response = await _apiClient.post(
      '/api/favorites/add',
      body: {
        'userId': userId,
        'songId': songId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add favorite song');
    }
  }

  Future<void> removeFavorite(int userId, String songId) async {
    final response = await _apiClient.post(
      '/api/favorites/remove',
      body: {
        'userId': userId,
        'songId': songId,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove favorite song');
    }
  }

}
