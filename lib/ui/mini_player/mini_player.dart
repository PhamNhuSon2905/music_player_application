import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';
import '../../widgets/playing_indicator.dart';
import '../providers/player_provider.dart';
import '../../data/model/song.dart';
import '../../data/repository/favorite_song_repository.dart';
import '../../service/token_storage.dart';
import '../../utils/toast_helper.dart'; // ✅ thêm dòng này

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
      ToastHelper.show(
        context,
        message: 'Đã xóa bài hát khỏi Yêu thích',
        isSuccess: false,
      );
    } else {
      await _favoriteSongRepository.addFavorite(_userId!, song.id);
      if (mounted) setState(() => _isFavorite = true);

      ToastHelper.show(
        context,
        message: 'Đã thêm bài hát vào Yêu thích',
        isSuccess: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final Song? song = player.currentSong;

    if (song == null || player.isNowPlayingOpen)
      return const SizedBox();

    return GestureDetector(
      onTap: () => player.setNowPlayingOpen(true),
      child: Container(
        height: 68,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, -1),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            /// Ảnh + hiệu ứng phát
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: (song.image.isEmpty || !song.image.startsWith("http"))
                      ? Image.asset(
                          "assets/musical_note.jpg",
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          song.image,
                          width: 52,
                          height: 52,
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

            /// Tên bài hát + ca sĩ
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
                              fontFamily: "SF Pro",
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                            blankSpace: 40.0,
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
                              fontFamily: "SF Pro",
                              color: Colors.black,
                              decoration: TextDecoration.none,
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
                      color: Colors.black54,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),

            /// Nút điều khiển
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _toggleFavorite(song),
                  child: Icon(
                    _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _isFavorite ? Colors.black : Colors.black,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      player.isPlaying ? player.pause() : player.play(),
                  child: Icon(
                    player.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => player.nextSong(),
                  child: const Icon(
                    Icons.skip_next_rounded,
                    color: Colors.black,
                    size: 24,
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
