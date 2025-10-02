import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/data/repository/favorite_song_repository.dart';
import 'package:music_player_application/service/token_storage.dart';
import 'package:music_player_application/ui/now_playing/playing.dart';
import 'package:provider/provider.dart';
import '../../widgets/base_scaffold.dart';
import '../../widgets/playing_indicator.dart';
import '../providers/player_provider.dart';

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
    final player = context.read<PlayerProvider>();
    await player.setQueue(favoriteSongs, startIndex: index);

    // Ẩn MiniPlayer
    player.setNowPlayingOpen(true);
    player.play();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return ChangeNotifierProvider.value(
          value: player,
          child: const NowPlaying(),
        );
      },
    );

    // Hiện lại MiniPlayer khi đóng
    player.setNowPlayingOpen(false);

    // reload lại danh sách yêu thích
    await loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(
        title: const Text('Bài hát yêu thích của bạn'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteSongs.isEmpty
          ? const Center(child: Text('Không có bài hát yêu thích nào.'))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: favoriteSongs.length,
        itemBuilder: (context, index) {
          final song = favoriteSongs[index];
          return SongTile(
            song: song,
            onTap: () => _openNowPlaying(index),
          );
        },
      ),
      withBottomNav: true,
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
            // Ảnh + chart overlay
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
                // Chart nhảy nhảy khi bài này đang phát
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
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
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
