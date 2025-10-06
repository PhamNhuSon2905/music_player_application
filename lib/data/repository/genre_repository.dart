import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/genre.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/data/source/genre_remote_source.dart';

class GenreRepository {
  final GenreRemoteDataSource remoteDataSource;

  GenreRepository(BuildContext context)
      : remoteDataSource = GenreRemoteDataSource(context);

  // Lấy toàn bộ thể loại nhạc
  Future<List<Genre>> fetchAllGenres() async {
    return await remoteDataSource.fetchAllGenres();
  }

  // Lấy danh sách bài hát theo thể loại
  Future<List<Song>> fetchSongsByGenreId(int genreId) async {
    return await remoteDataSource.fetchSongsByGenreId(genreId);
  }
}
