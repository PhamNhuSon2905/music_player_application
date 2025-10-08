import 'package:flutter/material.dart';
import 'package:music_player_application/data/model/genre.dart';

class GenreCard extends StatelessWidget {
  final Genre genre;
  final VoidCallback onTap;

  const GenreCard({super.key, required this.genre, required this.onTap});

  String _getGenreImage(String name) {
    final key = name.toLowerCase();
    if (key.contains('chill')) {
      return 'assets/card_image/Nhac_chill.jpg';
    } else if (key.contains('edm')) {
      return 'assets/card_image/Nhac_EDM.jpg';
    } else if (key.contains('us') ||
        key.contains('uk') ||
        key.contains('âu mỹ')) {
      return 'assets/card_image/Nhac_USUK.jpg';
    } else if (key.contains('buồn')) {
      return 'assets/card_image/Nhac_buon.jpg';
    } else if (key.contains('vu lan')) {
      return 'assets/card_image/Nhac_vu_lan.jpg';
    } else if (key.contains('trẻ')) {
      return 'assets/card_image/Nhac_viet.jpg';
    } else if (key.contains('trữ tình')) {
      return 'assets/card_image/Nhac_tru_tinh.jpg';
    } else {
      return 'assets/card_image/V_pop_nhac_viet.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(_getGenreImage(genre.name)),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.3),
              BlendMode.darken,
            ),
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(12),
        child: Text(
          genre.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
