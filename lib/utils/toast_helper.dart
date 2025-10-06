import 'package:flutter/material.dart';

class ToastHelper {
  static void show(
      BuildContext context, {
        required String message,
        bool isSuccess = true,
        Duration duration = const Duration(milliseconds: 1500),
      }) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return _ToastMessage(
          message: message,
          isSuccess: isSuccess,
          duration: duration,
        );
      },
    );

    overlay.insert(overlayEntry);
    Future.delayed(duration + const Duration(milliseconds: 400), overlayEntry.remove);
  }
}

class _ToastMessage extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final Duration duration;

  const _ToastMessage({
    required this.message,
    required this.isSuccess,
    required this.duration,
  });

  @override
  State<_ToastMessage> createState() => _ToastMessageState();
}

class _ToastMessageState extends State<_ToastMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _opacityAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08), // trượt khi xuất hiện
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    Future.delayed(widget.duration, () => _controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.36, // giữa màn hình
      left: width * 0.15,
      right: width * 0.15,
      child: FadeTransition(
        opacity: _opacityAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF000000).withValues( alpha: 0.86),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: "SF Pro",
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          decoration: TextDecoration.none,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
