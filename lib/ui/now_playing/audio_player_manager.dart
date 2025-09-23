import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_service/audio_service.dart';
import 'package:music_player_application/data/model/song.dart';

class AudioPlayerManager {
  AudioPlayerManager({required this.song});

  final player = AudioPlayer();
  late Stream<DurationState> durationState;
  Song song;

  Future<void> init() async {
    durationState = Rx.combineLatest3<Duration, Duration, Duration?, DurationState>(
      player.positionStream,
      player.bufferedPositionStream,
      player.durationStream,
          (position, buffered, total) => DurationState(
        progress: position,
        buffered: buffered,
        total: total,
      ),
    );

    await _setSource(song);
  }

  Future<void> updateSong(Song newSong) async {
    song = newSong;
    await _setSource(song);
    await player.play();
  }

  Future<void> _setSource(Song song) async {
    final Uri artUri = (song.image.isNotEmpty && song.image.startsWith('http'))
        ? Uri.parse(song.image)
        : Uri.parse("https://via.placeholder.com/150");

    await player.setAudioSource(
      AudioSource.uri(
        Uri.parse(song.source),
        // dùng MediaItem cho just_audio_background
        tag: MediaItem(
          id: song.id.toString(),
          title: song.title,
          album: song.album.isNotEmpty ? song.album : "Album không xác định",
          artist: song.artist.isNotEmpty ? song.artist : "Ca sĩ không xác định",
          artUri: artUri,
          extras: {
            'androidCompactActionIndices': [0, 1, 2],
            'androidNotificationActions': [
              'skipToPrevious',
              'stop',
              'skipToNext',
            ],
          }
        ),
      ),
    );
  }

  void dispose() {
    player.dispose();
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });

  final Duration progress;
  final Duration buffered;
  final Duration? total;
}
