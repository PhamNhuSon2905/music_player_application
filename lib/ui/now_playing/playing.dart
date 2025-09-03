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

class _NowPlayingPageState extends State<NowPlayingPage> with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimController;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;
  late double _currentAnimationPosition;
  bool _isShuffle = false;
  late LoopMode _loopMode;
  bool _isFavorite = false;

  late FavoriteSongRepository _favoriteSongRepository;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _currentAnimationPosition = 0.0;
    _song = widget.playingSong;
    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _audioPlayerManager = AudioPlayerManager(songUrl: _song.source);
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
    _loopMode = LoopMode.off;

    _initAudio();

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
    final favorites = await _favoriteSongRepository.fetchFavoriteSongsByUserId(_userId);

    print("Logged in user ID: $_userId");
    print("Current song ID: ${_song.id}");
    print("Fetched favorite song IDs: ${favorites.map((e) => e.songId).toList()}");

    setState(() {
      _isFavorite = favorites.any((fav) => fav.songId.toString() == _song.id.toString());
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _favoriteSongRepository.removeFavorite(_userId, _song.id.toString());
    } else {
      await _favoriteSongRepository.addFavorite(_userId, _song.id.toString());
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
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
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0).animate(_imageAnimController),
                  child: ClipOval(
                    child: (_song.image.isEmpty || !_song.image.startsWith('http'))
                        ? Image.asset('assets/musical_note.jpg', width: screenWidth - delta, height: screenWidth - delta, fit: BoxFit.cover)
                        : FadeInImage.assetNetwork(
                      placeholder: 'assets/musical_note.jpg',
                      image: _song.image,
                      width: screenWidth - delta,
                      height: screenWidth - delta,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/musical_note.jpg', width: screenWidth - delta, height: screenWidth - delta, fit: BoxFit.cover);
                      },
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
                          Text(_song.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(_song.artist, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      IconButton(
                        onPressed: _toggleFavorite,
                        icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                        color: _isFavorite ? Colors.red : Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: _progressBar()),
                Padding(padding: const EdgeInsets.all(8), child: _mediaButtons()),
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
        MediaButtonControl(function: _setShuffle, icon: Icons.shuffle, color: _getShuffleColor(), size: 24),
        MediaButtonControl(function: _setPrevSong, icon: Icons.skip_previous, color: Colors.deepPurple, size: 36),
        _playButton(),
        MediaButtonControl(function: _setNextSong, icon: Icons.skip_next, color: Colors.deepPurple, size: 36),
        MediaButtonControl(function: _setupRepeatOption, icon: _repeatingIcon(), color: _getRepeatingIconColor(), size: 24),
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
    return StreamBuilder(
      stream: _audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState;
        final playing = playState?.playing;

        if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
          _pauseRotationAnim();
          return const CircularProgressIndicator();
        } else if (playing != true) {
          return MediaButtonControl(
              function: () => _audioPlayerManager.player.play(), icon: Icons.play_arrow, color: Colors.deepPurple, size: 48);
        } else if (processingState != ProcessingState.completed) {
          _playRotationAnim();
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.pause();
                _pauseRotationAnim();
              },
              icon: Icons.pause,
              color: Colors.deepPurple,
              size: 48);
        } else {
          _stopRotationAnim();
          _resetRotationAnim();
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.seek(Duration.zero);
                _resetRotationAnim();
                _playRotationAnim();
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

  void _setNextSong() {
    if (_isShuffle) {
      _selectedItemIndex = Random().nextInt(widget.songs.length);
    } else if (_selectedItemIndex < widget.songs.length - 1) {
      _selectedItemIndex++;
    } else if (_loopMode == LoopMode.all) {
      _selectedItemIndex = 0;
    }

    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    _pauseRotationAnim();
    _resetRotationAnim();

    setState(() {
      _song = nextSong;
    });

    _initFavoriteState();
  }

  void _setPrevSong() {
    if (_isShuffle) {
      _selectedItemIndex = Random().nextInt(widget.songs.length);
    } else if (_selectedItemIndex > 0) {
      _selectedItemIndex--;
    } else if (_loopMode == LoopMode.all) {
      _selectedItemIndex = widget.songs.length - 1;
    }

    final prevSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(prevSong.source);
    _pauseRotationAnim();
    _resetRotationAnim();

    setState(() {
      _song = prevSong;
    });

    _initFavoriteState();
  }

  void _setupRepeatOption() {
    _loopMode = switch (_loopMode) {
      LoopMode.off => LoopMode.one,
      LoopMode.one => LoopMode.all,
      LoopMode.all => LoopMode.off,
    };
    setState(() => _audioPlayerManager.player.setLoopMode(_loopMode));
  }

  IconData _repeatingIcon() => switch (_loopMode) {
    LoopMode.one => Icons.repeat_one,
    LoopMode.all => Icons.repeat_on,
    _ => Icons.repeat,
  };

  Color? _getRepeatingIconColor() => _loopMode == LoopMode.off ? Colors.grey : Colors.purple;

  void _playRotationAnim() {
    _imageAnimController.forward(from: _currentAnimationPosition);
    _imageAnimController.repeat();
  }

  void _pauseRotationAnim() {
    _stopRotationAnim();
    _currentAnimationPosition = _imageAnimController.value;
  }

  void _resetRotationAnim() {
    _currentAnimationPosition = 0.0;
    _imageAnimController.value = 0.0;
  }

  void _stopRotationAnim() => _imageAnimController.stop();

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
