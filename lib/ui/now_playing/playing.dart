import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  Color _dominantColor = Colors.black;

  @override
  void initState() {
    super.initState();
    final player = context.read<PlayerProvider>();

    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _manager = AudioPlayerManager(
      provider: player,
      imageAnimController: _imageAnimController,
      context: context,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (player.currentSong != null) {
        await _initFavoriteState(player.currentSong!);
        await _updatePalette(player.currentSong!.image);
      }
    });

    player.addListener(() {
      final current = player.currentSong;
      if (current != null) {
        _initFavoriteState(current);
        _updatePalette(current.image);
      }
    });
  }

  Future<void> _updatePalette(String imageUrl) async {
    if (imageUrl.isEmpty || !imageUrl.startsWith("http")) return;
    try {
      final PaletteGenerator generator =
      await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(imageUrl),
        size: const Size(200, 200),
        maximumColorCount: 10,
      );
      if (generator.dominantColor != null) {
        setState(() {
          _dominantColor = generator.dominantColor!.color;
        });
      }
    } catch (e) {
      debugPrint("Không lấy được palette: $e");
    }
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
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
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
      return const Scaffold(body: Center(child: Text("Chưa chọn bài hát nào")));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        title: const Text(
          'Trình phát nhạc',
          style: TextStyle(
            fontSize: 20,
            fontFamily: "SF Pro",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.expand_more_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ảnh nền load bằng CachedNetworkImage
          (song.image.isEmpty || !song.image.startsWith("http"))
              ? Image.asset('assets/musical_note.jpg', fit: BoxFit.cover)
              : CachedNetworkImage(
            imageUrl: song.image,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(color: Colors.black),
            errorWidget: (context, url, error) =>
                Image.asset('assets/musical_note.jpg',
                    fit: BoxFit.cover),
          ),

          // Blur overlay
          Blur(
            blur: 10,
            blurColor: Colors.black.withOpacity(0.4),
            child: Container(),
          ),

          /// Nội dung
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(height: 56),
                Text(
                  song.album.isEmpty ? "Unknown Album" : song.album,
                  style: const TextStyle(color: Colors.white),
                ),
                const Text('_ __ _',
                    style: TextStyle(color: Colors.white)),
                const SizedBox(height: 8),

                // Đĩa nhạc xoay
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: RotationTransition(
                    key: ValueKey(song.image),
                    turns: _imageAnimController,
                    child: Container(
                      width: screenWidth - delta,
                      height: screenWidth - delta,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: (song.image.isEmpty ||
                            !song.image.startsWith("http"))
                            ? Image.asset('assets/musical_note.jpg',
                            fit: BoxFit.cover)
                            : CachedNetworkImage(
                          imageUrl: song.image,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              Image.asset('assets/musical_note.jpg',
                                  fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ),

                // Tên bài hát + nghệ sĩ
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.share_rounded),
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 24,
                              child: song.title.length > 20
                                  ? Marquee(
                                text: song.title,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                scrollAxis: Axis.horizontal,
                                blankSpace: 50,
                                velocity: 30,
                                pauseAfterRound: Duration(seconds: 1),
                                startPadding: 10.0,
                              )
                                  : Text(
                                song.title,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Text(song.artist,
                                style:
                                const TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: IconButton(
                          onPressed: () => _toggleFavorite(song),
                          icon: Icon(_isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline_rounded),
                          color: _isFavorite ? Colors.purple : Colors.grey,
                        ),
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
                      final state = snapshot.data ??
                          DurationState(
                            progress: player.player.position,
                            buffered: player.player.bufferedPosition,
                            total: player.player.duration,
                          );
                      return ProgressBar(
                        progress: state.progress,
                        buffered: state.buffered,
                        total: state.total ?? Duration.zero,
                        onSeek: player.seek,
                        barHeight: 3,
                        barCapShape: BarCapShape.round,
                        baseBarColor: Colors.white.withOpacity(0.3),
                        progressBarColor: Colors.white,
                        bufferedBarColor: Colors.white54,
                        thumbColor: Colors.white,
                        timeLabelTextStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
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
                        icon: const Icon(Icons.shuffle_rounded),
                        color:
                        player.isShuffle ? Colors.deepPurple : Colors.white,
                      ),
                      IconButton(
                        onPressed: () =>
                            context.read<PlayerProvider>().prevSong(),
                        icon: const Icon(Icons.skip_previous_rounded),
                        iconSize: 30,
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(
                          player.isPlaying
                              ? Icons.pause_circle_outline_rounded
                              : Icons.play_circle_outline_rounded,
                          size: 50,
                        ),
                        onPressed: () => player.isPlaying
                            ? player.pause()
                            : player.play(),
                        color: Colors.white,
                      ),
                      IconButton(
                        onPressed: () =>
                            context.read<PlayerProvider>().nextSong(),
                        icon: const Icon(Icons.skip_next_rounded),
                        iconSize: 30,
                        color: Colors.white,
                      ),
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
                          context
                              .read<PlayerProvider>()
                              .setLoopMode(nextMode);
                        },
                        icon: Icon(_repeatIcon(player.loopMode)),
                        color: player.loopMode == LoopMode.off
                            ? Colors.grey
                            : Colors.deepPurple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _repeatIcon(LoopMode mode) {
    switch (mode) {
      case LoopMode.one:
        return Icons.repeat_one_on_rounded;
      case LoopMode.all:
        return Icons.repeat_on_rounded;
      default:
        return Icons.repeat_rounded;
    }
  }

  @override
  void dispose() {
    _manager.dispose();
    _imageAnimController.dispose();
    super.dispose();
  }
}
