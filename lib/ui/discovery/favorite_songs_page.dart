import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/data/repository/favorite_song_repository.dart';
import 'package:music_player_application/service/token_storage.dart';
import 'package:music_player_application/ui/now_playing/playing.dart';

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
      print('[FavoriteSongsPage] Lỗi loadFavorites: $e');
      print(st);
      setState(() {
        isLoading = false;
        favoriteSongs = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NowPlaying(
                    songs: favoriteSongs,
                    playingSong: song,
                  ),
                ),
              );
            },
          );
        },
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipOval(
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/musical_note.jpg',
          image: song.image,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          imageErrorBuilder: (_, __, ___) =>
              Image.asset('assets/musical_note.jpg', width: 56, height: 56),
        ),
      ),
      title: Text(
        song.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
