import '../../utils/constants.dart';

class Song {
  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.source,
    required this.image,
    required this.duration,
    required this.createdAt,
  });

  String id;
  String title;
  String album;
  String artist;
  String source;
  String image;
  int duration;
  DateTime createdAt;




  static String normalizeUrl(String path) {
    if (path.startsWith('/')) {
      path = path.substring(1);
    }


    return '${AppConstants.baseUrl}/${Uri.encodeFull(path)}';


  }



  factory Song.fromJson(Map<String, dynamic> map) {
    final imageUrl = normalizeUrl(map['image'] ?? '');
    final sourceUrl = normalizeUrl(map['source'] ?? '');

    // print('Image URL: $imageUrl');
    // print('Audio URL: $sourceUrl');

    return Song(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      album: map['album'] ?? '',
      artist: map['artist'] ?? '',
      source: sourceUrl,
      image: imageUrl,
      duration: map['duration'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Song && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song{id: $id, title: $title, album: $album, artist: $artist, '
        'source: $source, image: $image, duration: $duration, createdAt: $createdAt}';
  }
}
