import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/playlist.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/data/repository/repository.dart';
import 'package:music_player_application/service/playlist_song_service.dart';

class AddSongToPlaylistPage extends StatefulWidget {
  final Playlist playlist;

  const AddSongToPlaylistPage({super.key, required this.playlist});

  @override
  State<AddSongToPlaylistPage> createState() => _AddSongToPlaylistPageState();
}

class _AddSongToPlaylistPageState extends State<AddSongToPlaylistPage> {
  late PlaylistSongService _playlistSongService;
  late DefaultRepository _songRepository;

  List<Song> _allSongs = [];
  List<Song> _filteredSongs = [];
  Set<String> _addedSongIds = {};

  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _playlistSongService = PlaylistSongService(context);
    _songRepository = DefaultRepository(context);
    _loadSongs();
  }

  void _showSnackBar({required String message, bool isSuccess = true}) {
    final color = isSuccess ? Colors.green : Colors.red;
    final icon = isSuccess ? Icons.check_circle : Icons.error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: "SF Pro",
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadSongs() async {
    final songs = await _songRepository.loadData() ?? [];
    final playlistSongs =
    await _playlistSongService.fetchSongsByPlaylist(widget.playlist.id);

    setState(() {
      _allSongs = songs;
      _filteredSongs = songs;
      _addedSongIds = playlistSongs.map((s) => s.id).toSet();
      _isLoading = false;
    });
  }

  void _onSearchChanged(String keyword) {
    if (keyword.trim().isEmpty) {
      setState(() => _filteredSongs = _allSongs);
    } else {
      setState(() {
        _filteredSongs = _allSongs
            .where(
              (s) =>
          s.title.toLowerCase().contains(keyword.toLowerCase()) ||
              s.artist.toLowerCase().contains(keyword.toLowerCase()),
        )
            .toList();
      });
    }
  }

  Future<void> _addSong(Song song) async {
    final success =
    await _playlistSongService.addSongToPlaylist(widget.playlist.id, song.id);

    if (success) {
      setState(() {
        _addedSongIds.add(song.id);
      });
      _showSnackBar(message: "Đã thêm '${song.title}' vào playlist!");
    } else {
      _showSnackBar(message: "Thêm bài hát thất bại!", isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _addedSongIds.isNotEmpty);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Thêm bài hát vào playlist"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Tìm kiếm bài hát để thêm vào playlist",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged("");
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSongs.isEmpty
                  ? const Center(child: Text("Không tìm thấy bài hát nào"))
                  : ListView.builder(
                itemCount: _filteredSongs.length,
                itemBuilder: (context, index) {
                  final song = _filteredSongs[index];
                  final alreadyAdded =
                  _addedSongIds.contains(song.id);

                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (song.image.isEmpty ||
                          !song.image.startsWith("http"))
                          ? Image.asset(
                        'assets/musical_note.jpg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                          : Image.network(
                        song.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Image.asset(
                              'assets/musical_note.jpg',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                      ),
                    ),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(song.artist),
                    trailing: alreadyAdded
                        ? const Icon(Icons.check, color: Colors.green)
                        : IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _addSong(song),
                    ),
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
