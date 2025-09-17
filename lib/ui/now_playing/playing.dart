import 'dart:math';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/data/repository/favorite_song_repository.dart';
import 'package:music_player_application/service/token_storage.dart';
import 'package:music_player_application/ui/now_playing/audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(songs: songs, playingSong: playingSong);
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({
    super.key,
    required this.songs,
    required this.playingSong,
  });

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimController;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;
  bool _isShuffle = false;
  late LoopMode _loopMode;
  bool _isFavorite = false;

  late FavoriteSongRepository _favoriteSongRepository;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _song = widget.playingSong;
    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _audioPlayerManager = AudioPlayerManager(songUrl: _song.source);
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
    _loopMode = LoopMode.off;

    _initAudio();

    _audioPlayerManager.player.playingStream.listen((isPlaying) {
      if (isPlaying) {
        _playRotationAnim();
      } else {
        _pauseRotationAnim();
      }
    });

    _audioPlayerManager.player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.ready && state.playing) {
        _playRotationAnim();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFavoriteState();
    });
  }

  Future<void> _initAudio() async {
    await _audioPlayerManager.init();
    setState(() {});
  }

  Future<void> _initFavoriteState() async {
    _userId = await TokenStorage.getUserId();
    _favoriteSongRepository = FavoriteSongRepository(context);
    final favorites =
    await _favoriteSongRepository.fetchFavoriteSongsByUserId(_userId);

    setState(() {
      _isFavorite =
          favorites.any((fav) => fav.songId.toString() == _song.id.toString());
    });
  }

  /// ✅ Hàm show SnackBar đẹp
  void _showSnackBar({required String message, bool isSuccess = true}) {
    final color = isSuccess ? Colors.green : Colors.red;
    final icon = isSuccess ? Icons.check_circle : Icons.error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: "SF Pro",
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _favoriteSongRepository.removeFavorite(_userId, _song.id);
      setState(() {
        _isFavorite = false;
      });
      _showSnackBar(
          message: 'Đã gỡ "${_song.title}" khỏi Yêu thích', isSuccess: false);
    } else {
      await _favoriteSongRepository.addFavorite(_userId, _song.id);
      setState(() {
        _isFavorite = true;
      });
      _showSnackBar(
          message: 'Đã thêm "${_song.title}" vào Yêu thích', isSuccess: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Trình Phát Nhạc'),
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz),
        ),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(height: 56),
                Text(_song.album),
                const Text('_ ___ _'),
                const SizedBox(height: 8),

                /// Đĩa nhạc quay
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: RotationTransition(
                    key: ValueKey(_song.image),
                    turns: _imageAnimController,
                    child: ClipOval(
                      child: (_song.image.isEmpty ||
                          !_song.image.startsWith('http'))
                          ? Image.asset(
                        'assets/musical_note.jpg',
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                        fit: BoxFit.cover,
                      )
                          : Image.network(
                        _song.image,
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Image.asset(
                            'assets/musical_note.jpg',
                            width: screenWidth - delta,
                            height: screenWidth - delta,
                            fit: BoxFit.cover,
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/musical_note.jpg',
                            width: screenWidth - delta,
                            height: screenWidth - delta,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Column(
                        children: [
                          Text(_song.title,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(_song.artist,
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      IconButton(
                        onPressed: _toggleFavorite,
                        icon: Icon(_isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border),
                        color: _isFavorite
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _progressBar()),
                Padding(
                    padding: const EdgeInsets.all(8), child: _mediaButtons()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mediaButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        MediaButtonControl(
            function: _setShuffle,
            icon: Icons.shuffle,
            color: _getShuffleColor(),
            size: 24),
        MediaButtonControl(
            function: _setPrevSong,
            icon: Icons.skip_previous,
            color: Colors.deepPurple,
            size: 36),
        _playButton(),
        MediaButtonControl(
            function: _setNextSong,
            icon: Icons.skip_next,
            color: Colors.deepPurple,
            size: 36),
        MediaButtonControl(
            function: _setupRepeatOption,
            icon: _repeatingIcon(),
            color: _getRepeatingIconColor(),
            size: 24),
      ],
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: _audioPlayerManager.durationState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        return ProgressBar(
          progress: state?.progress ?? Duration.zero,
          buffered: state?.buffered ?? Duration.zero,
          total: state?.total ?? Duration.zero,
          onSeek: _audioPlayerManager.player.seek,
          barHeight: 5,
          barCapShape: BarCapShape.round,
          baseBarColor: Colors.deepPurple.shade100,
          progressBarColor: Colors.deepPurple,
          bufferedBarColor: Colors.deepPurple.shade200,
          thumbColor: Colors.deepPurple,
        );
      },
    );
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState;
        final playing = playState?.playing;

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return const CircularProgressIndicator();
        } else if (playing != true) {
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.play();
              },
              icon: Icons.play_arrow,
              color: Colors.deepPurple,
              size: 48);
        } else if (processingState != ProcessingState.completed) {
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.pause();
              },
              icon: Icons.pause,
              color: Colors.deepPurple,
              size: 48);
        } else {
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.seek(Duration.zero);
                _audioPlayerManager.player.play();
              },
              icon: Icons.replay,
              color: Colors.deepPurple,
              size: 48);
        }
      },
    );
  }

  void _setShuffle() {
    setState(() => _isShuffle = !_isShuffle);
  }

  Color? _getShuffleColor() => _isShuffle ? Colors.deepPurple : Colors.grey;

  Future<void> _setNextSong() async {
    if (_isShuffle) {
      _selectedItemIndex = Random().nextInt(widget.songs.length);
    } else if (_selectedItemIndex < widget.songs.length - 1) {
      _selectedItemIndex++;
    } else if (_loopMode == LoopMode.all) {
      _selectedItemIndex = 0;
    }

    final nextSong = widget.songs[_selectedItemIndex];

    setState(() {
      _song = nextSong;
    });

    await _audioPlayerManager.updateSongUrl(nextSong.source);
    await _audioPlayerManager.player.play();

    _initFavoriteState();
  }

  Future<void> _setPrevSong() async {
    if (_isShuffle) {
      _selectedItemIndex = Random().nextInt(widget.songs.length);
    } else if (_selectedItemIndex > 0) {
      _selectedItemIndex--;
    } else if (_loopMode == LoopMode.all) {
      _selectedItemIndex = widget.songs.length - 1;
    }

    final prevSong = widget.songs[_selectedItemIndex];

    setState(() {
      _song = prevSong;
    });

    await _audioPlayerManager.updateSongUrl(prevSong.source);
    await _audioPlayerManager.player.play();

    _initFavoriteState();
  }

  void _setupRepeatOption() {
    _loopMode = switch (_loopMode) {
      LoopMode.off => LoopMode.one,
      LoopMode.one => LoopMode.all,
      LoopMode.all => LoopMode.off,
    };
    _audioPlayerManager.player.setLoopMode(_loopMode);
    setState(() {});
  }

  IconData _repeatingIcon() => switch (_loopMode) {
    LoopMode.one => Icons.repeat_one,
    LoopMode.all => Icons.repeat_on_rounded,
    _ => Icons.repeat,
  };

  Color? _getRepeatingIconColor() =>
      _loopMode == LoopMode.off ? Colors.grey : Colors.purple;

  void _playRotationAnim() {
    if (!_imageAnimController.isAnimating) {
      _imageAnimController.repeat();
    }
  }

  void _pauseRotationAnim() {
    _imageAnimController.stop(canceled: false);
  }

  @override
  void dispose() {
    _audioPlayerManager.dispose();
    _imageAnimController.dispose();
    super.dispose();
  }
}

class MediaButtonControl extends StatelessWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: function,
      icon: Icon(icon),
      iconSize: size,
      color: color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
