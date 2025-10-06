import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/data/source/playlist_song_remote_source.dart';

class PlaylistSongRepository {
  final PlaylistSongRemoteDataSource remoteDataSource;

  PlaylistSongRepository(BuildContext context)
    : remoteDataSource = PlaylistSongRemoteDataSource(context);
  // lấy tất cả bài hát có trong playlist của người dùng
  Future<List<Song>> fetchSongsByPlaylist(int playlistId) {
    return remoteDataSource.fetchSongsByPlaylist(playlistId);
  }
  // thêm bài hát vào playlist của người dùng
  Future<void> addSongToPlaylist(int playlistId, String songId) {
    return remoteDataSource.addSongToPlaylist(playlistId, songId);
  }
  // xóa bài hát khỏi playlist của người dùng
  Future<void> removeSongFromPlaylist(int playlistId, String songId) {
    return remoteDataSource.removeSongFromPlaylist(playlistId, songId);
  }
}
