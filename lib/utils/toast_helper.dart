import 'package:flutter/material.dart';

/// Dùng key này để truy cập overlay toàn app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ToastHelper {
  // gọi thông báo toàn cục
  static void showGlobal({
    required String message,
    bool isSuccess = true,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    final context = navigatorKey.currentContext;

    if (context == null) {
      Future.delayed(const Duration(milliseconds: 200), () {
        final retry = navigatorKey.currentContext;
        if (retry != null) {
          _safeShow(retry, message, isSuccess, duration);
        } else {
        }
      });
      return;
    }

    _safeShow(context, message, isSuccess, duration);
  }
  // hàm có context cục bộ
  static void show(
      BuildContext context, {
        required String message,
        bool isSuccess = true,
        Duration duration = const Duration(milliseconds: 1500),
      }) {
    _safeShow(context, message, isSuccess, duration);
  }


  static void _safeShow(
      BuildContext context,
      String message,
      bool isSuccess,
      Duration duration,
      ) {
    OverlayState? overlay = Overlay.maybeOf(context);

    overlay ??= navigatorKey.currentState?.overlay;

    if (overlay == null) {
      return;
    }

    final overlayEntry = OverlayEntry(
      builder: (context) => _ToastMessage(
        message: message,
        isSuccess: isSuccess,
        duration: duration,
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(duration + const Duration(milliseconds: 400), () {
      overlayEntry.remove();
    });
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
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    reverseDuration: const Duration(milliseconds: 250),
  );

  late final Animation<double> _opacityAnim =
  CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

  late final Animation<Offset> _slideAnim = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
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
      bottom: MediaQuery.of(context).size.height * 0.5,
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
                  color: const Color(0xFF000000).withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(6),
                ),
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
            ),
          ),
        ),
      ),
    );
  }
}
