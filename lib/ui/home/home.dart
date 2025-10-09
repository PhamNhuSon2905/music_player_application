import 'package:flutter/material.dart';
import 'package:music_player_application/ui/discovery/discovery.dart';
import 'package:music_player_application/ui/home/viewmodel.dart';
import 'package:music_player_application/ui/mini_player/mini_player.dart';
import 'package:music_player_application/ui/now_playing/playing_scope.dart';
import 'package:music_player_application/ui/settings/settings.dart';
import 'package:music_player_application/ui/user/user.dart';
import 'package:music_player_application/service/user_service.dart';
import 'package:music_player_application/utils/toast_helper.dart';
import 'package:provider/provider.dart';
import '../../data/model/song.dart';
import '../../widgets/playing_indicator.dart';
import '../now_playing/audio_helper.dart';
import '../providers/player_provider.dart';
import 'dart:async';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "SF Pro",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: "SF Pro"),
          bodyLarge: TextStyle(fontFamily: "SF Pro"),
          titleMedium: TextStyle(fontFamily: "SF Pro"),
        ),
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  int _currentIndex = 0;
  String? _avatarUrl;

  final List<Widget> _tabs = const [
    HomeTab(),
    DiscoveryTab(),
    AccountTab(),
    SettingsTab(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
  }

  Future<void> _loadUserAvatar() async {
    try {
      final userService = UserService(context);
      final user = await userService.getCurrentUser();
      if (mounted && user != null) {
        setState(() => _avatarUrl = user.fullAvatarUrl);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return PlayingScope(
      child: Scaffold(
        body: Stack(
          children: [
            _tabs[_currentIndex],
            Align(
              alignment: Alignment.bottomCenter,
              child: Consumer<PlayerProvider>(
                builder: (context, player, _) {
                  if (player.currentSong == null || player.isNowPlayingOpen) {
                    return const SizedBox();
                  }
                  return AnimatedOpacity(
                    opacity: player.isPlaying ? 1 : 0.9,
                    duration: const Duration(milliseconds: 300),
                    child: const MiniPlayer(),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.library_music_rounded),
              label: 'Thư Viện',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.adjust_rounded),
              label: 'Khám Phá',
            ),
            BottomNavigationBarItem(
              icon: _avatarUrl != null
                  ? Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _currentIndex == 2
                            ? LinearGradient(
                          colors: [
                            Colors.purple.shade200,
                            Colors.purple.shade50,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : const LinearGradient(
                          colors: [Colors.grey, Colors.grey],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 11,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(_avatarUrl!),
                      ),
                    )
                  : const Icon(Icons.person_rounded),
              label: 'Cá Nhân',
            ),

            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Cài Đặt',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) => const HomeTabPage();
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  List<Song> filteredSongs = [];
  late MusicAppViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs(context);
    observeData();
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    _searchController.dispose();
    super.dispose();
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      if (mounted) {
        setState(() {
          songs = songList;
          if (!isSearching) filteredSongs = List.from(songs);
        });
      }
    });
  }

  void _onSearchChanged(String keyword) {
    if (keyword.trim().isEmpty) {
      setState(() {
        isSearching = false;
        filteredSongs = List.from(songs);
      });
    } else {
      setState(() => isSearching = true);
      _searchSongs(keyword.trim());
    }
  }

  void _onSearchCleared() {
    _searchController.clear();
    setState(() {
      isSearching = false;
      filteredSongs = List.from(songs);
    });
  }

  Future<void> _searchSongs(String keyword) async {
    try {
      final result = await _viewModel.searchSongs(keyword, context);
      if (mounted) {
        if (result.isEmpty) {
          ToastHelper.show(
            context,
            message: "Không tìm thấy kết quả nào",
            isSuccess: false,
          );
        }
        setState(() => filteredSongs = result);
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.show(
          context,
          message: "Lỗi tìm kiếm: $e",
          isSuccess: false,
        );
        setState(() => filteredSongs = []);
      }
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bài hát, ca sĩ...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 22,
            color: Colors.grey,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: _onSearchCleared,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 12,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget getBody() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 0, 4),
            child: Text(
              "Thư viện",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: "SF Pro",
                color: Colors.black,
              ),
            ),
          ),
          _buildSearchBar(),
          Expanded(
            child: isSearching && filteredSongs.isEmpty
                ? const Center(
                    child: Text(
                      'Không tìm thấy kết quả nào',
                      style: TextStyle(fontFamily: "SF Pro", fontSize: 16),
                    ),
                  )
                : filteredSongs.isEmpty
                ? getProgressBar()
                : getListView(),
          ),
        ],
      ),
    );
  }

  Widget getProgressBar() =>
      const Center(child: CircularProgressIndicator(color: Colors.deepPurple));

  Widget getListView() {
    return ListView.builder(
      itemCount: filteredSongs.length,
      itemBuilder: (context, index) => _SongItemSection(
        song: filteredSongs[index],
        onTap: () => navigate(index),
        onMoreTap: () => showBottomSheet(filteredSongs[index]),
      ),
    );
  }

  void showBottomSheet(Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Tùy chọn",
              style: TextStyle(
                fontSize: 18,
                fontFamily: "SF Pro",
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.playlist_add_rounded),
              title: const Text('Thêm vào playlist'),
              onTap: () {
                Navigator.pop(context);
                ToastHelper.show(
                  context,
                  message: "Đã thêm vào playlist",
                  isSuccess: true,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: const Text('Tải xuống'),
              onTap: () {
                Navigator.pop(context);
                ToastHelper.show(
                  context,
                  message: "Đang tải xuống...",
                  isSuccess: true,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Chia sẻ'),
              onTap: () {
                Navigator.pop(context);
                ToastHelper.show(
                  context,
                  message: "Đã sao chép link bài hát",
                  isSuccess: true,
                );
              },
            ),
            const Divider(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Đóng',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "SF Pro",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigate(int index) {
    AudioPlayerHelper.playSong(
      context,
      songs: filteredSongs,
      startIndex: index,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: getBody());
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({
    required this.song,
    required this.onTap,
    required this.onMoreTap,
  });

  final Song song;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

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
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/musical_note.jpg',
                    image: song.image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) =>
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
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black),
              onPressed: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}
