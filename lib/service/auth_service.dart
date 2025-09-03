import 'package:flutter/material.dart';
import 'package:music_player_application/service/token_storage.dart';
import 'package:music_player_application/ui/auth/login_page.dart';

class AuthService {
  static Future<void> logout(BuildContext context) async {
    await TokenStorage.clearAll();


    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }
}
