import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_player_application/ui/settings/theme_notifier.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final isDark = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Chế độ tối'),
            value: isDark,
            onChanged: (_) => themeNotifier.toggleTheme(),
            secondary: const Icon(Icons.brightness_6),
          ),
        ],
      ),
    );
  }
}
