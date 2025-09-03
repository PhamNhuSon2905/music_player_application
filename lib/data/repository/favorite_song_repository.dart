import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/favorite_song.dart';

import '../model/song.dart';
import '../source/favorite_song_remote_source.dart';


class FavoriteSongRepository {
  final FavoriteSongRemoteDataSource remoteDataSource;

  FavoriteSongRepository(BuildContext context)
      : remoteDataSource = FavoriteSongRemoteDataSource(context);

  Future<List<FavoriteSong>> fetchFavoriteSongsByUserId(int userId) async {
    return await remoteDataSource.fetchFavoritesByUser(userId);
  }

  Future<List<Song>> fetchFavoriteSongsAsSongs(int userId) async {
    final favoriteSongs = await fetchFavoriteSongsByUserId(userId);
    return favoriteSongs.map((fav) {
      return Song.fromJson({
        'id': fav.songId,
        'title': fav.title,
        'album': fav.album,
        'artist': fav.artist,
        'source': fav.source,
        'image': fav.image,
        'duration': fav.duration,
        'createdAt': fav.createdAt.toIso8601String(),
      });
    }).toList();
  }


  Future<void> addFavorite(int userId, String songId) async {
    await remoteDataSource.addFavorite(userId, songId);
  }

  Future<void> removeFavorite(int userId, String songId) async {
    await remoteDataSource.removeFavorite(userId, songId);
  }
}
