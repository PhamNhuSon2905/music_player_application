import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player_application/utils/toast_helper.dart';
import '../../data/model/song.dart';
import '../../data/repository/favorite_song_repository.dart';
import '../../service/token_storage.dart';
import '../providers/player_provider.dart';

class AudioPlayerManager {
  final PlayerProvider provider;
  final AnimationController imageAnimController;
  final BuildContext context;
  late StreamSubscription<bool> _playingSub;
  late StreamSubscription<PlayerState> _playerStateSub;
  late FavoriteSongRepository _favoriteSongRepository;
  int _userId = 0;

  AudioPlayerManager({
    required this.provider,
    required this.imageAnimController,
    required this.context,
  }) {
    _initListeners();
    _initFavoriteRepo();
  }

  void _initListeners() {
    _playingSub = provider.player.playingStream.listen((isPlaying) {
      isPlaying ? _playRotationAnim() : _pauseRotationAnim();
    });

    _playerStateSub = provider.player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.ready && state.playing) {
        _playRotationAnim();
      } else if (state.processingState == ProcessingState.completed) {
        _pauseRotationAnim();
      }
    });
  }

  Future<void> _initFavoriteRepo() async {
    _userId = await TokenStorage.getUserId();
    _favoriteSongRepository = FavoriteSongRepository(context);
  }

  Future<void> toggleFavorite(
    Song song,
    bool isFavorite,
    Function(bool) callback,
  ) async {
    if (_userId == 0) {
      ToastHelper.show(
        context,
        message: "Không tìm thấy userId!",
        isSuccess: false,
      );
      return;
    }

    if (isFavorite) {
      await _favoriteSongRepository.removeFavorite(_userId, song.id);
      callback(false);
      ToastHelper.show(
        context,
        message: 'Đã gỡ "${song.title}" khỏi Yêu thích',
        isSuccess: false,
      );
    } else {
      await _favoriteSongRepository.addFavorite(_userId, song.id);
      callback(true);
      ToastHelper.show(
        context,
        message: 'Đã thêm "${song.title}" vào Yêu thích',
        isSuccess: true,
      );
    }
  }

  void _playRotationAnim() {
    if (!imageAnimController.isAnimating) {
      imageAnimController.repeat();
    }
  }

  void _pauseRotationAnim() {
    if (imageAnimController.isAnimating) {
      imageAnimController.stop(canceled: false);
    }
  }

  void dispose() {
    _playingSub.cancel();
    _playerStateSub.cancel();
  }
}
