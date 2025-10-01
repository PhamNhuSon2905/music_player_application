import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/genre.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/data/repository/genre_repository.dart';
import 'package:music_player_application/ui/now_playing/playing.dart';
import 'package:provider/provider.dart';
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

      // DEBUG: In thông tin bài hát, ảnh, source
      for (var song in data) {
        debugPrint("Tên bài hát: ${song.title}");
        debugPrint("Image URL: ${song.image}");
        debugPrint("Audio URL: ${song.source}");
      }

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

  void _openNowPlaying(int index) {
    context.read<PlayerProvider>().setQueue(songs, startIndex: index);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NowPlaying()),
    );
  }

  Widget _buildSongItem(Song song, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipOval(
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/musical_note.jpg',
          image: song.image,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          imageErrorBuilder: (_, error, stackTrace) {
            debugPrint("Failed to load image: ${song.image}");
            return Image.asset('assets/musical_note.jpg', width: 60, height: 60);
          },
        ),
      ),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () {
        debugPrint("Tapped song: ${song.title}");
        _openNowPlaying(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.genre.name),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : songs.isEmpty
          ? const Center(child: Text("Không có bài hát nào"))
          : ListView.separated(
        itemCount: songs.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        separatorBuilder: (_, __) =>
        const Divider(indent: 72, endIndent: 16),
        itemBuilder: (_, index) => _buildSongItem(songs[index], index),
      ),
    );
  }
}
