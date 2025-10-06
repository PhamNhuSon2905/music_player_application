import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/model/song.dart';
import '../providers/player_provider.dart';

class AudioPlayerHelper {
  static void playSong(
      BuildContext context, {
        required List<Song> songs,
        required int startIndex,
      }) {
    final player = context.read<PlayerProvider>();
    if (!player.isNowPlayingOpen) {
      player.setNowPlayingOpen(true);
    }
    unawaited(_prepareAndPlay(player, songs, startIndex));
  }
  static Future<void> _prepareAndPlay(
      PlayerProvider player,
      List<Song> songs,
      int startIndex,
      ) async {
    try {
      await player.setQueue(songs, startIndex: startIndex);
      player.play();
    } catch (e) {
      debugPrint("Lỗi khi phát bài hát: $e");
    }
  }
}
