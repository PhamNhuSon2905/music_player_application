import 'package:flutter/material.dart';
import 'package:music_player_application/ui/auth/login_page.dart';
import 'package:music_player_application/ui/providers/player_provider.dart';
import 'package:music_player_application/ui/splash_screen/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:music_player_application/utils/toast_helper.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> clearSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'music_player_channel',
    androidNotificationChannelName: 'Music Player',
    androidNotificationOngoing: true,
  );

  await clearSession();

  runApp(
    MultiProvider(
      providers: [
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
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: "SF Pro",
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        colorScheme: const ColorScheme.light(
          primary: Colors.deepPurple,
          secondary: Colors.purpleAccent,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
