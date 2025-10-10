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
  late Animation<double> _anim;
  double _dragStartY = 0;
  double _dragStartVal = 0;

  // cảm giác chạm kéo
  static const _snapThreshold = 0.15; // mở/đóng 0.15
  static const _minFlingVelocity = 100.0; // tốc độ vuốt tay

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeOutCubic);
  }

  bool get _isExpanded => _controller.value >= 0.999;

  void _syncWithProvider(PlayerProvider player) {

    if (player.isNowPlayingOpen && !_isExpanded) {
      _controller.forward();
    } else if (!player.isNowPlayingOpen && _isExpanded) {
      _controller.reverse();
    }
  }

  // kéo trên playing.dart full màn
  void _onDragStart(DragStartDetails details) {
    _dragStartY = details.globalPosition.dy;
    _dragStartVal = _controller.value;
  }

  void _onDragUpdate(DragUpdateDetails details, double screenHeight) {
    final delta = _dragStartY - details.globalPosition.dy; // kéo lên: +
    final dy = delta / screenHeight;
    _controller.value = (_dragStartVal + dy).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails details, PlayerProvider player) {
    final vy = details.primaryVelocity ?? 0; // kéo xuống -
    if (vy.abs() > _minFlingVelocity) {
      if (vy < 0) {
        // kéo lên → mở
        _controller.fling(velocity: 2.0);
        player.setNowPlayingOpen(true);
      } else {
        // xuống → đóng
        _controller.animateTo(0.0, curve: Curves.easeOutExpo, duration: const Duration(milliseconds: 250));
        player.setNowPlayingOpen(false);
      }
      return;
    }

    if (_controller.value >= _snapThreshold) {
      _controller.forward();
      player.setNowPlayingOpen(true);
    } else {
      _controller.reverse();
      player.setNowPlayingOpen(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final h = MediaQuery.of(context).size.height;

    // Đồng bộ sau frame để tránh setState trong build
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncWithProvider(player));

    return Stack(
      children: [
        widget.child,

        // Lớp playing: di chuyển từ dưới lên theo _anim
        if (player.currentSong != null)
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              final offsetY = h * (1 - _anim.value); // value=0: ẩn dưới, 1: hiển thị toàn màn
              return Transform.translate(
                offset: Offset(0, offsetY),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragStart: _onDragStart,
                  onVerticalDragUpdate: (d) => _onDragUpdate(d, h),
                  onVerticalDragEnd: (d) => _onDragEnd(d, player),
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
