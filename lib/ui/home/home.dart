import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player_application/ui/discovery/discovery.dart';
import 'package:music_player_application/ui/home/viewmodel.dart';
import 'package:music_player_application/ui/now_playing/playing.dart';
import 'package:music_player_application/ui/settings/settings.dart';
import 'package:music_player_application/ui/user/user.dart';

import '../../data/model/song.dart';

// Giữ nguyên MaterialApp của bạn
class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Thêm màu nền để đồng bộ
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Cấu trúc trang chính với CupertinoTabScaffold
class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    // Sử dụng Scaffold thay cho CupertinoPageScaffold để tùy biến AppBar dễ hơn
    // và vẫn giữ được CupertinoTabBar
    return Scaffold(
      body: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Colors.white,
          activeColor: Colors.deepPurple,
          inactiveColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.music_house_fill), label: 'Thư Viện'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.compass_fill), label: 'Khám Phá'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.person_fill), label: 'Cá Nhân'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings_solid), label: 'Cài Đặt'),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: const Text('Zing MP3 Music',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.white,
              border: null, // Bỏ đường viền dưới
            ),
            child: _tabs[index],
          );
        },
      ),
    );
  }
}

// HomeTab không thay đổi
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

// HomeTabPage với giao diện được làm mới
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
    _viewModel.loadSongs(context); // Giả sử hàm này load dữ liệu
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
          if (!isSearching) {
            filteredSongs = List.from(songs);
          }
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
      setState(() {
        isSearching = true;
      });
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
        setState(() {
          filteredSongs = result;
        });
      }
    } catch (e) {
      print('Lỗi khi tìm kiếm: $e');
      if (mounted) {
        setState(() {
          filteredSongs = [];
        });
      }
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: CupertinoSearchTextField(
        controller: _searchController,
        placeholder: 'Tìm kiếm bài hát, nghệ sĩ...',
        onChanged: _onSearchChanged,
        onSuffixTap: _onSearchCleared,
      ),
    );
  }

  Widget getBody() {
    return SafeArea(
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: isSearching && filteredSongs.isEmpty
                ? const Center(child: Text('Không tìm thấy kết quả nào'))
                : filteredSongs.isEmpty
                ? getProgressBar()
                : getListView(),
          ),
        ],
      ),
    );
  }

  Widget getProgressBar() => Center(
    child: CircularProgressIndicator(
      color: Colors.deepPurple,
    ),
  );

  Widget getListView() {
    return ListView.builder(
      itemCount: filteredSongs.length,
      itemBuilder: (context, index) =>
          _SongItemSection(
            song: filteredSongs[index],
            onTap: () => navigate(filteredSongs[index]),
            onMoreTap: () => showBottomSheet(),
          ),
    );
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Tùy chọn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Thêm vào playlist'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Tải xuống'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Chia sẻ'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void navigate(Song song) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) =>
            NowPlaying(songs: filteredSongs, playingSong: song),
      ),
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
            // Album Image
            ClipOval(
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/musical_note.jpg',
                image: song.image,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/musical_note.jpg',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

            const SizedBox(width: 16),
            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // More Button
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.grey),
              onPressed: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}