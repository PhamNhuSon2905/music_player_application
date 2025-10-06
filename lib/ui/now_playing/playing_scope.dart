import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../now_playing/playing.dart';
import '../providers/player_provider.dart';

class PlayingScope extends StatefulWidget {
  final Widget child;
  const PlayingScope({super.key, required this.child});

  @override
  State<PlayingScope> createState() => _PlayingScopeState();
}

class _PlayingScopeState extends State<PlayingScope>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragStartY = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  bool get _isExpanded => _controller.value == 1.0;

  void _onDragStart(DragStartDetails details) {
    _dragStartY = details.globalPosition.dy;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final dragDelta = _dragStartY - details.globalPosition.dy;
    final screenHeight = MediaQuery.of(context).size.height;
    final progressDelta = dragDelta / screenHeight;
    _controller.value = (_controller.value + progressDelta).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails details, PlayerProvider player) {
    const minFlingVelocity = 500.0;
    final velocity = details.primaryVelocity ?? 0;

    if (velocity < -minFlingVelocity) {
      _controller.forward();
      player.setNowPlayingOpen(true);
    } else if (velocity > minFlingVelocity) {
      _controller.reverse();
      player.setNowPlayingOpen(false);
    } else {
      if (_controller.value > 0.5) {
        _controller.forward();
        player.setNowPlayingOpen(true);
      } else {
        _controller.reverse();
        player.setNowPlayingOpen(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final screenHeight = MediaQuery.of(context).size.height;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (player.isNowPlayingOpen && !_isExpanded) {
        _controller.forward();
      } else if (!player.isNowPlayingOpen && _isExpanded) {
        _controller.reverse();
      }
    });

    return Stack(
      children: [
        widget.child,

        if (player.currentSong != null)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final offsetY = screenHeight * (1 - _animation.value);
              return Transform.translate(
                offset: Offset(0, offsetY),
                child: GestureDetector(
                  onVerticalDragStart: _onDragStart,
                  onVerticalDragUpdate: _onDragUpdate,
                  onVerticalDragEnd: (details) => _onDragEnd(details, player),
                  child: AbsorbPointer(
                    absorbing: !_isExpanded,
                    child: const NowPlaying(),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
