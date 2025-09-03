class FavoriteSong {
  final String songId;
  final String title;
  final String album;
  final String artist;
  final String source;
  final String image;
  final int duration;
  final DateTime createdAt;

  FavoriteSong({
    required this.songId,
    required this.title,
    required this.album,
    required this.artist,
    required this.source,
    required this.image,
    required this.duration,
    required this.createdAt,
  });

  factory FavoriteSong.fromJson(Map<String, dynamic> json) {
    return FavoriteSong(
      songId: json['id'],
      title: json['title'],
      album: json['album'],
      artist: json['artist'],
      source: json['source'],
      image: json['image'],
      duration: json['duration'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
