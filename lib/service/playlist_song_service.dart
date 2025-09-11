import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/playlist_song.dart';
import 'package:music_player_application/data/repository/playlist_song_repository.dart';

class PlaylistSongService {
  final PlaylistSongRepository _repo;
  final BuildContext context;

  PlaylistSongService(this.context) : _repo = PlaylistSongRepository(context);

  /// Lấy danh sách bài hát trong playlist
  Future<List<PlaylistSong>> fetchSongsByPlaylist(int playlistId) async {
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Bài hát đã được thêm vào playlist!"),
          ),
        );
      }

      return true;
    } catch (e) {
      debugPrint("Lỗi addSongToPlaylist: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Thêm bài hát vào playlist thất bại!"),
          ),
        );
      }
      return false;
    }
  }

  /// Xóa bài hát khỏi playlist
  Future<bool> removeSongFromPlaylist(int playlistSongId) async {
    try {
      await _repo.removeSongFromPlaylist(playlistSongId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Bài hát đã được xóa khỏi playlist!"),
          ),
        );
      }

      return true;
    } catch (e) {
      debugPrint("Lỗi removeSongFromPlaylist: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Xóa bài hát khỏi playlist thất bại!"),
          ),
        );
      }
      return false;
    }
  }
}
