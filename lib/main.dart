import 'package:flutter/material.dart';
import 'package:music_player_application/ui/auth/login_page.dart';
import 'package:music_player_application/ui/providers/player_provider.dart';
import 'package:music_player_application/ui/settings/theme_notifier.dart';
import 'package:music_player_application/ui/splash_screen/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> clearSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init JustAudioBackground view notification
  await JustAudioBackground.init(
    androidNotificationChannelId: 'music_player_channel',
    androidNotificationChannelName: 'Music Player',
    androidNotificationOngoing: true,
  );

  await clearSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeNotifier.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C2C),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFBB86FC),
          secondary: Color(0xFF03DAC6),
          surface: Color(0xFF2C2C2C),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Colors.purpleAccent),
          trackColor: MaterialStateProperty.all(Colors.purple.withValues(alpha: 0.5)),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
