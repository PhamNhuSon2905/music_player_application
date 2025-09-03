import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/data/source/source.dart';

abstract interface class Repository {
  Future<List<Song>?> loadData();
  Future<Song?> getSongById(String id);
  Future<List<Song>> searchSongs(String keyword);
}

class DefaultRepository implements Repository {
  final RemoteDataSource _remoteDataSource;

  DefaultRepository(BuildContext context)
      : _remoteDataSource = RemoteDataSource(context);

  @override
  Future<List<Song>?> loadData() async {
    final remoteSongs = await _remoteDataSource.loadData();
    return remoteSongs;
  }

  @override
  Future<Song?> getSongById(String id) {
    return _remoteDataSource.getSongById(id);
  }

  @override
  Future<List<Song>> searchSongs(String keyword) {
    return _remoteDataSource.searchSongs(keyword);
  }
}
