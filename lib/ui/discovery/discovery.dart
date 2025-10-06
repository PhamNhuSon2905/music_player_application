import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/genre.dart';
import 'package:music_player_application/data/model/playlist.dart';
import 'package:music_player_application/data/repository/genre_repository.dart';
import 'package:music_player_application/data/repository/playlist_repository.dart';
import 'package:music_player_application/service/token_storage.dart';
import 'package:music_player_application/utils/toast_helper.dart';
import '../../playlist_song/playlist_detail_page.dart';
import 'favorite_songs_page.dart';
import 'genre_card.dart';
import 'package:music_player_application/ui/playlist/create_playlist_page.dart';
import 'package:music_player_application/ui/playlist/update_playlist_page.dart';
import 'genre_view_model.dart';
// banner_slider
import 'banners/banner_slider.dart';

class DiscoveryTab extends StatefulWidget {
  const DiscoveryTab({super.key});

  @override
  State<DiscoveryTab> createState() => _DiscoveryTabState();
}

class _DiscoveryTabState extends State<DiscoveryTab> {
  List<Genre> genres = [];
  List<Playlist> playlists = [];
  String? username;

  bool isLoadingGenres = true;
  bool isLoadingPlaylists = true;

  @override
  void initState() {
    super.initState();
    _loadGenres();
    _loadPlaylists();
    _loadUserName();
  }

  Future<void> _loadGenres() async {
    final repo = GenreRepository(context);
    final data = await repo.fetchAllGenres();
    setState(() {
      genres = data;
      isLoadingGenres = false;
    });
  }

  Future<void> _loadPlaylists() async {
    final userId = await TokenStorage.getUserId();
    final repo = PlaylistRepository(context);

    try {
      final data = await repo.fetchPlaylistsByUser(userId);
      setState(() {
        playlists = data;
        isLoadingPlaylists = false;
      });
    } catch (e) {
      debugPrint("Lỗi load playlist: $e");
      setState(() {
        playlists = [];
        isLoadingPlaylists = false;
      });
    }
  }

  Future<void> _loadUserName() async {
    final name = await TokenStorage.getUsername();
    setState(() {
      username = name ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Khám phá âm nhạc',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          // Banner slider
          const BannerSlider(),

          // Chủ đề & Thể loại nhạc
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Chủ đề & Thể loại nhạc',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isLoadingGenres)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  final genre = genres[index];
                  return GenreCard(
                    genre: genre,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GenreSongPage(genre: genre),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

          // Bài hát yêu thích
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Bài hát yêu thích của bạn',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoriteSongsPage()),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/banner/banner_favorite.jpg',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Playlist của bạn
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Playlist của bạn',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          isLoadingPlaylists
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: playlists.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // Nút tạo playlist
                return GestureDetector(
                  onTap: () async {
                    final newPlaylist = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreatePlaylistPage(),
                      ),
                    );
                    if (newPlaylist != null){
                      await _loadPlaylists();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.add,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Tạo playlist",
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final playlist = playlists[index - 1];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaylistDetailPage(
                        playlist: playlist,
                        username: username ?? "",
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: playlist.hasServerImage
                            ? Image.network(
                          playlist.fullImageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                            : Image.asset(
                          playlist.fullImageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playlist.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              username ?? "",
                              style: const TextStyle(
                                fontFamily: 'SF Pro',
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        icon: const Icon(Icons.more_vert, color: Colors.black87),
                        onSelected: (value) async {
                          final repo = PlaylistRepository(context);
                          if (value == "edit") {
                            final updatedPlaylist = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UpdatePlaylistPage(
                                  playlist: playlist,
                                ),
                              ),
                            );
                            if (updatedPlaylist != null){
                              await _loadPlaylists();
                            }
                          } else if (value == "delete") {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Xóa Playlist"),
                                content: Text(
                                  "Bạn có chắc muốn xóa playlist '${playlist.name}' không?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("Hủy"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      "Xóa",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              try {
                                await repo.deletePlaylist(playlist.id);
                                _loadPlaylists();
                                ToastHelper.show(
                                  context,
                                  message: "Đã xóa playlist '${playlist.name}'",
                                  isSuccess: true,
                                );
                              } catch (e) {
                                if (mounted) {
                                  ToastHelper.show(
                                    context,
                                    message:
                                    "Không thể xóa playlist. Vui lòng thử lại!",
                                    isSuccess: false,
                                  );
                                }
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: "edit",
                            child: Row(
                              children: [
                                Icon(Icons.edit,
                                    size: 18, color: Colors.black87),
                                SizedBox(width: 8),
                                Text("Sửa playlist"),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: "delete",
                            child: Row(
                              children: [
                                Icon(Icons.delete,
                                    size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  "Xóa playlist",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Mới phát hành
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Mới phát hành',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 120,
            child: Center(
              child: Text(
                'Coming soon...',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
