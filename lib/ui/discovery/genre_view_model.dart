import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/genre.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/data/repository/genre_repository.dart';
import 'package:music_player_application/ui/now_playing/playing.dart';
import 'package:provider/provider.dart';
import '../../widgets/base_scaffold.dart';
import '../../widgets/playing_indicator.dart';
import '../providers/player_provider.dart';

class GenreSongPage extends StatefulWidget {
  final Genre genre;

  const GenreSongPage({super.key, required this.genre});

  @override
  State<GenreSongPage> createState() => _GenreSongPageState();
}

class _GenreSongPageState extends State<GenreSongPage> {
  List<Song> songs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  Future<void> _fetchSongs() async {
    try {
      final repo = GenreRepository(context);
      final data = await repo.fetchSongsByGenreId(widget.genre.id);

      setState(() {
        songs = data;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint("Failed to fetch songs: $e");
      debugPrint(stackTrace.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openNowPlaying(int index) async {
    final player = context.read<PlayerProvider>();
    await player.setQueue(songs, startIndex: index);

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

    player.setNowPlayingOpen(false);
  }

  Widget _buildSongItem(Song song, int index) {
    return InkWell(
      onTap: () => _openNowPlaying(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Ảnh bài hát + Chart overlay
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
                // Chart khi bài này đang phát
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

            // Nút more (nếu muốn thêm options sau này)
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.grey),
              onPressed: () {
                // TODO: thêm menu tuỳ chọn giống HomeTab nếu cần
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(
        title: Text(widget.genre.name),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : songs.isEmpty
          ? const Center(child: Text("Không có bài hát nào"))
          : ListView.builder(
        itemCount: songs.length,
        itemBuilder: (_, index) => _buildSongItem(songs[index], index),
      ),
      withBottomNav: true,
    );
  }
}
