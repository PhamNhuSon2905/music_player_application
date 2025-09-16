import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/data/source/playlist_song_remote_source.dart';

class PlaylistSongRepository {
  final PlaylistSongRemoteDataSource remoteDataSource;

  PlaylistSongRepository(BuildContext context)
      : remoteDataSource = PlaylistSongRemoteDataSource(context);

  Future<List<Song>> fetchSongsByPlaylist(int playlistId) {
    return remoteDataSource.fetchSongsByPlaylist(playlistId);
  }

  Future<void> addSongToPlaylist(int playlistId, String songId) {
    return remoteDataSource.addSongToPlaylist(playlistId, songId);
  }

  Future<void> removeSongFromPlaylist(int playlistId, String songId) {
    return remoteDataSource.removeSongFromPlaylist(playlistId, songId);
  }
}
