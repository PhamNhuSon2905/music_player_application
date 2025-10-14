import 'dart:io';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/model/song.dart';
import '../../data/repository/favorite_song_repository.dart';
import '../../service/token_storage.dart';
import '../../service/dowload_service.dart';
import '../../utils/toast_helper.dart';
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
  bool _isDownloaded = false;
  bool _isDownloading = false;

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
        await _checkIfDownloaded(player.currentSong!);
      }
    });

    player.addListener(() {
      final current = player.currentSong;
      if (current != null) {
        _initFavoriteState(current);
        _updatePalette(current.image);
        _checkIfDownloaded(current);
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

      if (!mounted) return;

      if (generator.dominantColor != null) {
        setState(() => _dominantColor = generator.dominantColor!.color);
      }
    } catch (e) {
      debugPrint("Không lấy được palette: $e");
    }
  }

  Future<void> _initFavoriteState(Song song) async {
    _userId = await TokenStorage.getUserId();
    _favoriteSongRepository = FavoriteSongRepository(context);

    final favorites = await _favoriteSongRepository.fetchFavoriteSongsByUserId(
      _userId,
    );

    if (!mounted) return;

    setState(() {
      _isFavorite = favorites.any(
        (fav) => fav.songId.toString() == song.id.toString(),
      );
    });
  }

  Future<void> _checkIfDownloaded(Song song) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/App_Music');
      if (!folder.existsSync()) {
        setState(() => _isDownloaded = false);
        return;
      }

      final safeTitle = song.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final safeArtist = song.artist.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final safeAlbum = song.album.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final fileName = "${safeTitle}_${safeArtist}_${safeAlbum}.mp3";
      final filePath = "${folder.path}/$fileName";
      final fileExists = await File(filePath).exists();
      if (!mounted) return;

      setState(() => _isDownloaded = fileExists);
    } catch (e) {
      debugPrint("Lỗi kiểm tra file tải: $e");
    }
  }

  Future<void> _toggleFavorite(Song song) async {
    if (_isFavorite) {
      await _favoriteSongRepository.removeFavorite(_userId, song.id);
      if (!mounted) return;
      setState(() => _isFavorite = false);
      ToastHelper.show(
        context,
        message: 'Đã xóa bài hát khỏi Yêu thích',
        isSuccess: false,
      );
    } else {
      await _favoriteSongRepository.addFavorite(_userId, song.id);
      if (!mounted) return;
      setState(() => _isFavorite = true);
      ToastHelper.show(
        context,
        message: 'Đã thêm bài hát vào Yêu thích',
        isSuccess: true,
      );
    }
  }

  Future<void> _handleDownload(Song song) async {
    if (_isDownloaded) {
      ToastHelper.show(
        context,
        message: "Bài hát đã có trong thiết bị!",
        isSuccess: true,
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isDownloading = true);

    final safeTitle = song.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final safeArtist = song.artist.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final safeAlbum = song.album.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final fileName = "${safeTitle}_${safeArtist}_${safeAlbum}.mp3";

    await DownloadService.downloadSong(url: song.source, fileName: fileName);

    await _checkIfDownloaded(song);

    if (!mounted) return;
    setState(() => _isDownloading = false);
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
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          (song.image.isEmpty || !song.image.startsWith("http"))
              ? Image.asset('assets/musical_note.jpg', fit: BoxFit.cover)
              : CachedNetworkImage(
                  imageUrl: song.image,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.black),
                  errorWidget: (_, __, ___) =>
                      Image.asset('assets/musical_note.jpg', fit: BoxFit.cover),
                ),
          Blur(
            blur: 20,
            blurColor: Colors.black.withValues(alpha: 0.05),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.05),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTopBar(context, player),
                _buildAlbumInfo(song, screenWidth, delta),
                _buildTitleAndFavorite(song),
                _buildProgressBar(player),
                _buildControls(player),
                _buildBottomIcons(song),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, PlayerProvider player) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.expand_more_rounded, color: Colors.white),
            iconSize: 36,
            onPressed: () =>
                context.read<PlayerProvider>().setNowPlayingOpen(false),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Trình phát nhạc',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "SF Pro",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
            iconSize: 36,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumInfo(Song song, double screenWidth, double delta) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            song.album.isEmpty ? "Unknown Album" : song.album,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: "SF Pro",
            ),
          ),
        ),
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
                child: (song.image.isEmpty || !song.image.startsWith("http"))
                    ? Image.asset('assets/musical_note.jpg', fit: BoxFit.cover)
                    : CachedNetworkImage(
                        imageUrl: song.image,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Image.asset(
                          'assets/musical_note.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndFavorite(Song song) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(Icons.ios_share_rounded, color: Colors.grey),
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 24,
                  child: song.title.length > 20
                      ? Marquee(
                          text: song.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          scrollAxis: Axis.horizontal,
                          blankSpace: 50,
                          velocity: 30,
                          pauseAfterRound: Duration(seconds: 1),
                        )
                      : Text(
                          song.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                ),
                Text(
                  song.artist,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () => _toggleFavorite(song),
              icon: Icon(
                _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
              ),
              color: _isFavorite ? Colors.purple : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(PlayerProvider player) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: StreamBuilder<DurationState>(
        stream: player.durationState,
        builder: (context, snapshot) {
          final state =
              snapshot.data ??
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
            baseBarColor: Colors.white.withValues(alpha: 0.3),
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
    );
  }

  Widget _buildControls(PlayerProvider player) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: IconButton(
                onPressed: () => context.read<PlayerProvider>().toggleShuffle(),
                icon: const Icon(Icons.shuffle_rounded),
                iconSize: 24,
                color: player.isShuffle ? Colors.deepPurple : Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: IconButton(
                onPressed: () => context.read<PlayerProvider>().prevSong(),
                icon: const Icon(Icons.skip_previous_rounded),
                iconSize: 40,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: IconButton(
                icon: Icon(
                  player.isPlaying
                      ? Icons.pause_circle_outline_rounded
                      : Icons.play_circle_outline_rounded,
                  size: 65,
                ),
                onPressed: () =>
                    player.isPlaying ? player.pause() : player.play(),
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: IconButton(
                onPressed: () => context.read<PlayerProvider>().nextSong(),
                icon: const Icon(Icons.skip_next_rounded),
                iconSize: 40,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: IconButton(
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
                iconSize: 24,
                color: player.loopMode == LoopMode.off
                    ? Colors.grey
                    : Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomIcons(Song song) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Expanded(
            child: Center(
              child: Icon(
                Icons.color_lens_outlined,
                color: Colors.grey,
                size: 24,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Icon(
                Icons.playlist_add_outlined,
                color: Colors.grey,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "320 Kbps",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : IconButton(
                      onPressed: () => _handleDownload(song),
                      icon: Icon(
                        Icons.arrow_circle_down_rounded,
                        color: _isDownloaded ? Colors.deepPurple : Colors.grey,
                        size: 26,
                      ),
                    ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Icon(
                Icons.queue_music_rounded,
                color: Colors.grey,
                size: 24,
              ),
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
