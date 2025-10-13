import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/model/song.dart';
import '../../utils/toast_helper.dart';
import '../now_playing/audio_helper.dart';
import '../now_playing/playing_scope.dart';
import '../mini_player/mini_player.dart';
import '../providers/player_provider.dart';
import '../../widgets/playing_indicator.dart';

class DownloadedSongsPage extends StatefulWidget {
  const DownloadedSongsPage({super.key});

  @override
  State<DownloadedSongsPage> createState() => _DownloadedSongsPageState();
}

class _DownloadedSongsPageState extends State<DownloadedSongsPage> {
  List<Song> downloadedSongs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedSongs();
  }

  Future<void> _loadDownloadedSongs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final folderPath = prefs.getString("download_music_app");

      if (folderPath == null) {
        setState(() {
          isLoading = false;
          downloadedSongs = [];
        });
        ToastHelper.show(context,
            message: "Chưa chọn thư mục tải nhạc!", isSuccess: false);
        return;
      }

      final dir = Directory(folderPath);
      if (!dir.existsSync()) {
        setState(() {
          isLoading = false;
          downloadedSongs = [];
        });
        ToastHelper.show(context,
            message: "Thư mục không tồn tại!", isSuccess: false);
        return;
      }

      final files = dir
          .listSync()
          .where((f) =>
      f is File && f.path.toLowerCase().endsWith('.mp3'))
          .toList();

      final List<Song> songs = files.map((file) {
        final name = file.uri.pathSegments.last;
        final cleanName = name.replaceAll('.mp3', '');
        final parts = cleanName.split('_');
        String title = parts.isNotEmpty ? parts[0].trim() : "Không xác định";
        String artist = parts.length > 1 ? parts[1].trim() : "Không xác định";
        String album = parts.length > 2 ? parts[2].trim() : "Không xác định";

        return Song(
          id: file.path,
          title: title,
          artist: artist,
          album: album,
          image: '',
          source: file.path, // đường dẫn local
          duration: 0,
          createdAt: DateTime.now(),
        );
      }).toList();

      setState(() {
        downloadedSongs = songs;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi khi quét bài hát offline: $e');
      setState(() {
        isLoading = false;
        downloadedSongs = [];
      });
    }
  }

  void _playSong(int index) {
    AudioPlayerHelper.playSong(
      context,
      songs: downloadedSongs,
      startIndex: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlayingScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Bài hát đã tải xuống trên thiết bị',
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
            ? const Center(
            child:
            CircularProgressIndicator(color: Colors.deepPurple))
            : downloadedSongs.isEmpty
            ? const Center(
          child: Text(
            'Không tìm thấy bài hát nào trong thiết bị.',
            style: TextStyle(
              fontFamily: "SF Pro",
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        )
            : Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: downloadedSongs.length,
              itemBuilder: (context, index) {
                final song = downloadedSongs[index];
                return _SongTile(
                  song: song,
                  onTap: () => _playSong(index),
                );
              },
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

class _SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _SongTile({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/musical_note.jpg', // ảnh mặc định
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
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
