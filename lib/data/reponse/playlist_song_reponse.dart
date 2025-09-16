import '../model/song.dart';

class PlaylistSongResponse {
  final String songId;
  final String title;
  final String album;
  final String artist;
  final String source;
  final String imageUrl;
  final int duration;
  final DateTime createdAt;
  final bool added;
  final DateTime addedAt;

  PlaylistSongResponse({
    required this.songId,
    required this.title,
    required this.album,
    required this.artist,
    required this.source,
    required this.imageUrl,
    required this.duration,
    required this.createdAt,
    required this.added,
    required this.addedAt,
  });

  factory PlaylistSongResponse.fromJson(Map<String, dynamic> json) {
    return PlaylistSongResponse(
      songId: json['songId'] ?? '',
      title: json['title'] ?? '',
      album: json['album'] ?? '',
      artist: json['artist'] ?? '',
      source: Song.normalizeUrl(json['source'] ?? ''),
      imageUrl: Song.normalizeUrl(json['image'] ?? ''),
      duration: json['duration'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      added: json['added'] ?? false,
      addedAt: DateTime.tryParse(json['addedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Song toSong() {
    return Song(
      id: songId,
      title: title,
      album: album,
      artist: artist,
      source: source,
      image: imageUrl,
      duration: duration,
      createdAt: createdAt,
    );
  }
}
