import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/playlist.dart';
import 'package:music_player_application/data/source/playlist_remote_source.dart';

class PlaylistRepository {
  final PlaylistRemoteDataSource remoteDataSource;

  PlaylistRepository(BuildContext context)
      : remoteDataSource = PlaylistRemoteDataSource(context);

  Future<List<Playlist>> fetchPlaylistsByUser(int userId) {
    return remoteDataSource.fetchPlaylistsByUser(userId);
  }

  Future<Playlist> createPlaylist(String name, String? imagePath, int userId) {
    return remoteDataSource.createPlaylist(name, imagePath, userId);
  }

  Future<void> deletePlaylist(int playlistId) {
    return remoteDataSource.deletePlaylist(playlistId);
  }
}
