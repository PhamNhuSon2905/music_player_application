import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';
import '../../widgets/playing_indicator.dart';
import '../providers/player_provider.dart';
import '../../data/model/song.dart';
import '../now_playing/playing.dart';
import '../../data/repository/favorite_song_repository.dart';
import '../../service/token_storage.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  bool _isFavorite = false;
  late FavoriteSongRepository _favoriteSongRepository;
  int? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _favoriteSongRepository = FavoriteSongRepository(context);
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final player = context.read<PlayerProvider>();
    final song = player.currentSong;
    if (song == null) return;

    _userId = await TokenStorage.getUserId();
    if (_userId == null) return;

    final favorites = await _favoriteSongRepository.fetchFavoriteSongsByUserId(
      _userId!,
    );

    if (mounted) {
      setState(() {
        _isFavorite = favorites.any((fav) => fav.songId.toString() == song.id);
      });
    }
  }

  Future<void> _toggleFavorite(Song song) async {
    if (_userId == null) return;

    if (_isFavorite) {
      await _favoriteSongRepository.removeFavorite(_userId!, song.id);
      if (mounted) setState(() => _isFavorite = false);
      _showSnackBar('Đã gỡ "${song.title}" khỏi Yêu thích', false);
    } else {
      await _favoriteSongRepository.addFavorite(_userId!, song.id);
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

    if (song == null || player.isNowPlayingOpen) return const SizedBox();

    return GestureDetector(
      onTap: () async {
        player.setNowPlayingOpen(true);

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          builder: (context) {
            return ChangeNotifierProvider.value(
              value: player,
              child: const NowPlaying(),
            );
          },
        );

        player.setNowPlayingOpen(false);
      },
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // bo góc
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, -1), // bóng đổ nhẹ phía trên
              blurRadius: 2,
            ),
          ],
        ),

        child: Row(
          children: [
            // Ảnh + hiệu ứng đang phát
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (song.image.isEmpty || !song.image.startsWith("http"))
                      ? Image.asset(
                          "assets/musical_note.jpg",
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          song.image,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                ),
                if (player.isPlaying && player.currentSong?.id == song.id)
                  const Positioned.fill(
                    child: Center(child: PlayingIndicator(isPlaying: true)),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Tên bài + ca sĩ
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                    child: song.title.length > 20
                        ? Marquee(
                            text: song.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            scrollAxis: Axis.horizontal,
                            blankSpace: 50.0,
                            velocity: 30.0,
                            pauseAfterRound: Duration(seconds: 1),
                          )
                        : Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: "SF Pro",
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _toggleFavorite(song),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorite ? Colors.black : Colors.black,
                      size: 16,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      player.isPlaying ? player.pause() : player.play(),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => player.nextSong(),
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: Icon(Icons.skip_next_rounded, color: Colors.black, size: 24),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
