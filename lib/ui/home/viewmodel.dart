import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_player_application/data/repository/repository.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/service/token_storage.dart';

class MusicAppViewModel {
  final StreamController<List<Song>> songStream = StreamController();

  Future<void> loadSongs(BuildContext context) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      print("Chưa đăng nhập, không thể tải danh sách bài hát.");
      return;
    }

    try {
      final repository = DefaultRepository(context);
      final data = await repository.loadData();
      if (data != null) {
        songStream.add(data);
      } else {
        print("Không có dữ liệu bài hát.");
      }
    } catch (e) {
      print("Lỗi khi load bài hát: $e");
    }
  }

  /// Tìm kiếm bài hát theo từ khóa tên bài hát, ca sĩ, album
  Future<List<Song>> searchSongs(String keyword, BuildContext context) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      print("Chưa đăng nhập, không thể tìm kiếm.");
      return [];
    }

    try {
      final repository = DefaultRepository(context);
      final result = await repository.searchSongs(keyword);
      return result;
    } catch (e) {
      print("Lỗi khi tìm kiếm bài hát: $e");
      return [];
    }
  }

  void dispose() {
    songStream.close();
  }
}
