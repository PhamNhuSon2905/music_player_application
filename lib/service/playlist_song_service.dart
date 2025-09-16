import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/data/repository/playlist_song_repository.dart';

class PlaylistSongService {
  final PlaylistSongRepository _repo;
  final BuildContext context;

  PlaylistSongService(this.context) : _repo = PlaylistSongRepository(context);

  /// Lấy danh sách bài hát trong playlist
  Future<List<Song>> fetchSongsByPlaylist(int playlistId) async {
    try {
      return await _repo.fetchSongsByPlaylist(playlistId);
    } catch (e) {
      debugPrint("Lỗi fetchSongsByPlaylist: $e");
      return [];
    }
  }

  /// Thêm bài hát vào playlist
  Future<bool> addSongToPlaylist(int playlistId, String songId) async {
    try {
      await _repo.addSongToPlaylist(playlistId, songId);
      return true;
    } catch (e) {
      debugPrint("Lỗi addSongToPlaylist: $e");
      return false;
    }
  }

  /// Xóa bài hát khỏi playlist
  Future<bool> removeSongFromPlaylist(int playlistId, String songId) async {
    try {
      await _repo.removeSongFromPlaylist(playlistId, songId);
      return true;
    } catch (e) {
      debugPrint("Lỗi removeSongFromPlaylist: $e");
      return false;
    }
  }
}
