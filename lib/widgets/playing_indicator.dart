import 'dart:math';
import 'package:flutter/material.dart';

class PlayingIndicator extends StatefulWidget {
  final bool isPlaying;
  const PlayingIndicator({super.key, required this.isPlaying});

  @override
  State<PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<PlayingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // tốc độ vừa phải
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _sinHeight(double t, double offset) {
    // dao động từ 6 -> 26
    return 6 + (sin(t + offset) + 1) * 10;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying) {
      return const SizedBox();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value * 2 * pi; // từ 0 -> 2π
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (i) {
            return Container(
              width: 3,
              height: _sinHeight(t, i * pi / 2), // lệch pha mỗi cột
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              color: Colors.white,
            );
          }),
        );
      },
    );
  }
}
