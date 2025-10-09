import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/playlist.dart';
import 'package:music_player_application/data/model/song.dart';
import 'package:music_player_application/service/playlist_song_service.dart';
import 'package:music_player_application/utils/toast_helper.dart';
import 'package:provider/provider.dart';
import '../ui/now_playing/audio_helper.dart';
import '../ui/providers/player_provider.dart';
import '../widgets/playing_indicator.dart';
import '../ui/mini_player/mini_player.dart';
import '../ui/now_playing/playing_scope.dart';
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

  Future<void> _loadSongs() async {
    final songs = await _playlistSongService.fetchSongsByPlaylist(
      widget.playlist.id,
    );
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
      ToastHelper.show(context, message: "Đã thêm bài hát mới vào playlist!");
    }
  }

  Future<void> _openNowPlaying(int index) async {
    AudioPlayerHelper.playSong(
      context,
      songs: _songs,
      startIndex: index,
    );
  }


  Future<void> _confirmDeleteSong(Song song) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa bài hát"),
        content: Text("Bạn có chắc muốn xóa '${song.title}' khỏi playlist không?"),
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
        ToastHelper.show(
          context,
          message: "Đã xóa '${song.title}' khỏi playlist",
          isSuccess: true,
        );
      } else {
        ToastHelper.show(
          context,
          message: "Xóa thất bại, vui lòng thử lại!",
          isSuccess: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlist = widget.playlist;

    return PlayingScope(
      child: Scaffold(
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
            ? const Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        )
            : Stack(
          children: [
            /// Nội dung chính
            Column(
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
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      return ListTile(
                        leading: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius:
                              BorderRadius.circular(12),
                              child: FadeInImage.assetNetwork(
                                placeholder:
                                'assets/musical_note.jpg',
                                image: song.image,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                imageErrorBuilder: (context, error,
                                    stackTrace) =>
                                    Image.asset(
                                      'assets/musical_note.jpg',
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                              ),
                            ),
                            Consumer<PlayerProvider>(
                              builder: (context, player, _) {
                                final isCurrent =
                                    player.currentSong?.id ==
                                        song.id;
                                final isPlaying = isCurrent &&
                                    player.isPlaying;
                                return isPlaying
                                    ? const PlayingIndicator(
                                  isPlaying: true,
                                )
                                    : const SizedBox();
                              },
                            ),
                          ],
                        ),
                        title: Text(
                          song.title,
                          style: const TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          song.artist,
                          style: const TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _openNowPlaying(index),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.black,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(8),
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
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
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

            Align(
              alignment: Alignment.bottomCenter,
              child: Consumer<PlayerProvider>(
                builder: (context, player, _) {
                  if (player.currentSong == null ||
                      player.isNowPlayingOpen) {
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
