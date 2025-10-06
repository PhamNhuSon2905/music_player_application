import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNav ??
          (withBottomNav
              ? const SizedBox(height: kBottomNavigationBarHeight)
              : null),
    );
  }
}
