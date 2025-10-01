import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/model/song.dart';
import '../../data/repository/favorite_song_repository.dart';
import '../../service/token_storage.dart';
import '../providers/player_provider.dart';
import 'audio_player_manager.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying({super.key});

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimController;
  late AudioPlayerManager _manager;

  bool _isFavorite = false;
  late FavoriteSongRepository _favoriteSongRepository;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    final player = context.read<PlayerProvider>();

    _imageAnimController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20));

    _manager = AudioPlayerManager(
      provider: player,
      imageAnimController: _imageAnimController,
      context: context,



    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (player.currentSong != null) {
        await _initFavoriteState(player.currentSong!);
      }
    });

    player.addListener(() {
      final current = player.currentSong;
      if (current != null) {
        _initFavoriteState(current);
      }
    });
  }

  Future<void> _initFavoriteState(Song song) async {
    _userId = await TokenStorage.getUserId();
    _favoriteSongRepository = FavoriteSongRepository(context);

    final favorites =
    await _favoriteSongRepository.fetchFavoriteSongsByUserId(_userId);

    if (mounted) {
      setState(() {
        _isFavorite =
            favorites.any((fav) => fav.songId.toString() == song.id.toString());
      });
    }
  }

  Future<void> _toggleFavorite(Song song) async {
    if (_isFavorite) {
      await _favoriteSongRepository.removeFavorite(_userId, song.id);
      if (mounted) setState(() => _isFavorite = false);
      _showSnackBar('Đã gỡ "${song.title}" khỏi Yêu thích', false);
    } else {
      await _favoriteSongRepository.addFavorite(_userId, song.id);
      if (mounted) setState(() => _isFavorite = true);
      _showSnackBar('Đã thêm "${song.title}" vào Yêu thích', true);
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        content: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.error,
                color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final Song? song = player.currentSong;

    if (song == null) {
      return const Scaffold(
        body: Center(child: Text("Chưa chọn bài hát nào")),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trình Phát Nhạc'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(height: 56),
              Text(song.album.isEmpty ? "Unknown Album" : song.album),
              const Text('_ __ _'),
              const SizedBox(height: 8),

              // Ảnh xoay
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: RotationTransition(
                  key: ValueKey(song.image),
                  turns: _imageAnimController,
                  child: ClipOval(
                    child: (song.image.isEmpty || !song.image.startsWith("http"))
                        ? Image.asset(
                      'assets/musical_note.jpg',
                      width: screenWidth - delta,
                      height: screenWidth - delta,
                      fit: BoxFit.cover,
                    )
                        : Image.network(
                      song.image,
                      width: screenWidth - delta,
                      height: screenWidth - delta,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/musical_note.jpg',
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                        fit: BoxFit.cover,
                      ),
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
                        Text(song.title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(song.artist,
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _toggleFavorite(song),
                      icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border),
                      color: _isFavorite ? Colors.red : Colors.deepPurple,
                    ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: StreamBuilder<DurationState>(
                  stream: player.durationState,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    return ProgressBar(
                      progress: state?.progress ?? Duration.zero,
                      buffered: state?.buffered ?? Duration.zero,
                      total: state?.total ?? Duration.zero,
                      onSeek: player.seek,
                      barHeight: 5,
                      barCapShape: BarCapShape.round,
                      baseBarColor: Colors.deepPurple.shade100,
                      progressBarColor: Colors.deepPurple,
                      bufferedBarColor: Colors.deepPurple.shade200,
                      thumbColor: Colors.deepPurple,
                    );
                  },
                ),
              ),

              // Nút điều khiển
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () =>
                          context.read<PlayerProvider>().toggleShuffle(),
                      icon: const Icon(Icons.shuffle),
                      color:
                      player.isShuffle ? Colors.deepPurple : Colors.grey,
                    ),

                    // Prev
                    IconButton(
                      onPressed: () =>
                          context.read<PlayerProvider>().prevSong(),
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 36,
                      color: Colors.deepPurple,
                    ),

                    // Play/Pause
                    IconButton(
                      icon: Icon(
                        player.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 48,
                      ),
                      onPressed: () =>
                      player.isPlaying ? player.pause() : player.play(),
                      color: Colors.deepPurple,
                    ),

                    // Next
                    IconButton(
                      onPressed: () =>
                          context.read<PlayerProvider>().nextSong(),
                      icon: const Icon(Icons.skip_next),
                      iconSize: 36,
                      color: Colors.deepPurple,
                    ),

                    // Repeat
                    IconButton(
                      onPressed: () {
                        final current = player.loopMode;
                        LoopMode nextMode;
                        switch (current) {
                          case LoopMode.off:
                            nextMode = LoopMode.one;
                            break;
                          case LoopMode.one:
                            nextMode = LoopMode.all;
                            break;
                          case LoopMode.all:
                            nextMode = LoopMode.off;
                            break;
                        }
                        context.read<PlayerProvider>().setLoopMode(nextMode);
                      },
                      icon: Icon(_repeatIcon(player.loopMode)),
                      color: player.loopMode == LoopMode.off
                          ? Colors.grey
                          : Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _repeatIcon(LoopMode mode) {
    switch (mode) {
      case LoopMode.one:
        return Icons.repeat_one;
      case LoopMode.all:
        return Icons.repeat_on_rounded;
      default:
        return Icons.repeat;
    }
  }

  @override
  void dispose() {
    _manager.dispose();
    _imageAnimController.dispose();
    super.dispose();
  }
}
