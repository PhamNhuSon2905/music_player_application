import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/data/repository/favorite_song_repository.dart';
import 'package:music_player_application/service/token_storage.dart';
import 'package:provider/provider.dart';
import '../../widgets/base_scaffold.dart';
import '../../widgets/playing_indicator.dart';
import '../now_playing/audio_helper.dart';
import '../providers/player_provider.dart';
import '../now_playing/playing_scope.dart';
import '../mini_player/mini_player.dart';

class FavoriteSongsPage extends StatefulWidget {
  const FavoriteSongsPage({super.key});

  @override
  State<FavoriteSongsPage> createState() => _FavoriteSongsPageState();
}

class _FavoriteSongsPageState extends State<FavoriteSongsPage> {
  List<Song> favoriteSongs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final userId = await TokenStorage.getUserId();
      if (userId == null) {
        setState(() {
          isLoading = false;
          favoriteSongs = [];
        });
        return;
      }

      final repo = FavoriteSongRepository(context);
      final songs = await repo.fetchFavoriteSongsAsSongs(userId);
      setState(() {
        favoriteSongs = songs;
        isLoading = false;
      });
    } catch (e, st) {
      debugPrint('[FavoriteSongsPage] Lỗi loadFavorites: $e\n$st');
      setState(() {
        isLoading = false;
        favoriteSongs = [];
      });
    }
  }


  Future<void> _openNowPlaying(int index) async {
    AudioPlayerHelper.playSong(
      context,
      songs: favoriteSongs,
      startIndex: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlayingScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Bài hát yêu thích của bạn',
            style: TextStyle(
              fontFamily: "SF Pro",
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
            : favoriteSongs.isEmpty
            ? const Center(
          child: Text(
            'Không có bài hát yêu thích nào.',
            style: TextStyle(
              fontFamily: "SF Pro",
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        )
            : Stack(
          children: [
            /// Danh sách bài hát
            ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final song = favoriteSongs[index];
                return SongTile(
                  song: song,
                  onTap: () => _openNowPlaying(index),
                );
              },
            ),

            // miniplayer nằm trên appbar dưới
            Align(
              alignment: Alignment.bottomCenter,
              child: Consumer<PlayerProvider>(
                builder: (context, player, _) {
                  if (player.currentSong == null || player.isNowPlayingOpen) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: kBottomNavigationBarHeight + 6,
                      left: 8,
                      right: 8,
                    ),
                    child: const MiniPlayer(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const SongTile({super.key, required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Ảnh bài hát + hiệu ứng playing
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (song.image.isEmpty || !song.image.startsWith("http"))
                      ? Image.asset(
                    'assets/musical_note.jpg',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    song.image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/musical_note.jpg',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Consumer<PlayerProvider>(
                  builder: (context, player, _) {
                    final isCurrent = player.currentSong?.id == song.id;
                    final isPlaying = isCurrent && player.isPlaying;
                    return isPlaying
                        ? const PlayingIndicator(isPlaying: true)
                        : const SizedBox();
                  },
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Thông tin bài hát
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontFamily: "SF Pro",
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: "SF Pro",
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
