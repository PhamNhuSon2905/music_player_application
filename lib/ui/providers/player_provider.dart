import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/model/song.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  late Stream<DurationState> durationState;

  ConcatenatingAudioSource? _playlist;
  Song? _currentSong;
  List<Song> _queue = [];
  int _currentIndex = 0;

  bool _isShuffle = false;

  // ✅ Thêm để quản lý trạng thái NowPlaying
  bool _isNowPlayingOpen = false;
  bool get isNowPlayingOpen => _isNowPlayingOpen;

  void setNowPlayingOpen(bool value) {
    _isNowPlayingOpen = value;
    notifyListeners();
  }

  Song? get currentSong => _currentSong;
  bool get isPlaying => _player.playing;
  bool get isShuffle => _isShuffle;
  LoopMode get loopMode => _player.loopMode;
  AudioPlayer get player => _player;

  PlayerProvider() {
    durationState = Rx.combineLatest3<Duration, Duration, Duration?, DurationState>(
      _player.positionStream,
      _player.bufferedPositionStream,
      _player.durationStream,
          (position, buffered, total) => DurationState(
        progress: position,
        buffered: buffered,
        total: total,
      ),
    ).asBroadcastStream();

    // Lắng nghe sự thay đổi index (update currentSong)
    _player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _queue.length) {
        _currentIndex = index;
        _currentSong = _queue[_currentIndex];
        notifyListeners();
      }
    });

    // Khi bài hát kết thúc
    _player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        if (_player.loopMode == LoopMode.off) {
          await _player.stop();
          notifyListeners();
        }
        // LoopMode.one và LoopMode.all đã được just_audio tự xử lý
      }
    });
  }

  /// Set queue
  Future<void> setQueue(List<Song> songs, {int startIndex = 0}) async {
    _queue = songs;
    _currentIndex = startIndex;

    _playlist = ConcatenatingAudioSource(
      children: songs.map((s) {
        final artUri = (s.image.isNotEmpty && s.image.startsWith('http'))
            ? Uri.parse(s.image)
            : Uri.parse("https://via.placeholder.com/150");

        return AudioSource.uri(
          Uri.parse(s.source),
          tag: MediaItem(
            id: s.id.toString(),
            title: s.title,
            album: s.album.isNotEmpty ? s.album : "Album không xác định",
            artist: s.artist.isNotEmpty ? s.artist : "Ca sĩ không xác định",
            artUri: artUri,
          ),
        );
      }).toList(),
    );

    await _player.setAudioSource(_playlist!, initialIndex: startIndex);
    _currentSong = songs[startIndex];
    notifyListeners();
    play();
  }

  /// Next Song
  Future<void> nextSong() async {
    if (_queue.isEmpty) return;

    if (_isShuffle) {
      int nextIndex = _currentIndex;
      while (nextIndex == _currentIndex && _queue.length > 1) {
        nextIndex = Random().nextInt(_queue.length);
      }
      _currentIndex = nextIndex;
      await _player.seek(Duration.zero, index: _currentIndex);
    } else {
      _currentIndex = (_currentIndex + 1) % _queue.length;
      await _player.seek(Duration.zero, index: _currentIndex);
    }
  }

  /// Previous Song
  Future<void> prevSong() async {
    if (_queue.isEmpty) return;

    if (_isShuffle) {
      int prevIndex = _currentIndex;
      while (prevIndex == _currentIndex && _queue.length > 1) {
        prevIndex = Random().nextInt(_queue.length);
      }
      _currentIndex = prevIndex;
      await _player.seek(Duration.zero, index: _currentIndex);
    } else {
      _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
      await _player.seek(Duration.zero, index: _currentIndex);
    }
  }

  void play() {
    _player.play();
    notifyListeners();
  }

  void pause() {
    _player.pause();
    notifyListeners();
  }

  void seek(Duration position) {
    _player.seek(position);
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    _player.setShuffleModeEnabled(false);
    notifyListeners();
  }

  /// Set Repeat mode (off, one, all)
  void setLoopMode(LoopMode mode) {
    _player.setLoopMode(mode);
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
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
