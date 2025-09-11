import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/playlist.dart';
import 'package:music_player_application/data/repository/playlist_repository.dart';

class PlaylistService {
  final PlaylistRepository _repo;
  final BuildContext context;

  PlaylistService(this.context) : _repo = PlaylistRepository(context);

  /// Lấy tất cả playlist theo userId
  Future<List<Playlist>> fetchPlaylistsByUser(int userId) async {
    try {
      return await _repo.fetchPlaylistsByUser(userId);
    } catch (e) {
      debugPrint("Lỗi fetchPlaylistsByUser: $e");
      return [];
    }
  }

  /// Tạo playlist mới
  Future<Playlist?> createPlaylist(String name, String? imagePath, int userId) async {
    try {
      final playlist = await _repo.createPlaylist(name, imagePath, userId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Playlist đã được tạo thành công!"),
          ),
        );
      }

      return playlist;
    } catch (e) {
      debugPrint("Lỗi createPlaylist: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Tạo playlist thất bại!"),
          ),
        );
      }
      return null;
    }
  }

  /// Xóa playlist
  Future<bool> deletePlaylist(int playlistId) async {
    try {
      await _repo.deletePlaylist(playlistId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("🗑 Playlist đã được xóa thành công!"),
          ),
        );
      }

      return true;
    } catch (e) {
      debugPrint("Lỗi deletePlaylist: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Xóa playlist thất bại!"),
          ),
        );
      }
      return false;
    }
  }
}
