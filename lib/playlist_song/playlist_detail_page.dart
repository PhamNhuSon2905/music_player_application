import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/playlist.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/service/playlist_song_service.dart';
import 'package:music_player_application/ui/now_playing/playing.dart';

import 'add_song_to_playlist_page.dart';

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;
  final String username;

  const PlaylistDetailPage({
    super.key,
    required this.playlist,
    required this.username,
  });

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  late PlaylistSongService _playlistSongService;
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _playlistSongService = PlaylistSongService(context);
    _loadSongs();
  }

  /// snackbar đẹp
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _loadSongs() async {
    final songs =
    await _playlistSongService.fetchSongsByPlaylist(widget.playlist.id);
    setState(() {
      _songs = songs;
      _isLoading = false;
    });
  }

  void _navigateToAddSong() async {
    final added = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddSongToPlaylistPage(playlist: widget.playlist),
      ),
    );

    if (added == true) {
      _loadSongs();
      _showSnackBar(message: "Đã thêm bài hát vào playlist!");
    }
  }

  void _openNowPlaying(Song song) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NowPlaying(
          playingSong: song,
          songs: _songs,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteSong(Song song) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa bài hát"),
        content:
        Text("Bạn có chắc muốn xóa '${song.title}' khỏi playlist không?"),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Xóa"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final removed = await _playlistSongService.removeSongFromPlaylist(
        widget.playlist.id,
        song.id,
      );
      if (removed) {
        _loadSongs();
        _showSnackBar(
          message: "Đã xóa '${song.title}' khỏi playlist",
          isSuccess: true,
        );
      } else {
        _showSnackBar(
          message: "Xóa thất bại, vui lòng thử lại!",
          isSuccess: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlist = widget.playlist;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          playlist.name,
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: playlist.hasServerImage
                      ? Image.network(
                    playlist.fullImageUrl,
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    playlist.fullImageUrl,
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  playlist.name,
                  style: const TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.username,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _navigateToAddSong,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.black12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    "Thêm bài hát vào playlist",
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _songs.isEmpty
                ? const Center(
              child: Text(
                "Không có bài hát trong playlist của bạn",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (context, index) {
                final song = _songs[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(song.image),
                    onBackgroundImageError: (_, __) {},
                  ),
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(song.artist),
                  onTap: () => _openNowPlaying(song),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: Colors.black),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _confirmDeleteSong(song);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text("Xóa khỏi playlist"),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
