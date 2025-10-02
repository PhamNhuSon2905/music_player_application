import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/mini_player/mini_player.dart';
import '../ui/providers/player_provider.dart';

class BaseScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final BottomNavigationBar? bottomNav;
  final bool withBottomNav;

  const BaseScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNav,
    this.withBottomNav = false,
  });

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (player.currentSong != null && !player.isNowPlayingOpen)
            const MiniPlayer(),
          if (bottomNav != null) bottomNav!,
          if (bottomNav == null && withBottomNav)
            const SizedBox(height: kBottomNavigationBarHeight),
        ],
      ),
    );
  }
}
