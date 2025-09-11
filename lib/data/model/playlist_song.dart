import 'song.dart';

class PlaylistSong {
  final int id;
  final Song song;
  final DateTime addedAt;

  PlaylistSong({
    required this.id,
    required this.song,
    required this.addedAt,
  });

  factory PlaylistSong.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;

    return PlaylistSong(
      id: id,
      song: Song.fromJson(json['song']),
      addedAt: DateTime.parse(json['addedAt'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'song': {
        'id': song.id,
        'title': song.title,
        'album': song.album,
        'artist': song.artist,
        'source': song.source,
        'image': song.image,
        'duration': song.duration,
        'createdAt': song.createdAt.toIso8601String(),
      },
      'addedAt': addedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PlaylistSong{id: $id, song: ${song.title}, addedAt: $addedAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PlaylistSong && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
