import '../../utils/constants.dart';

class Playlist {
  final int id;
  final String name;
  final String image;
  final DateTime? createdAt;

  Playlist({
    required this.id,
    required this.name,
    required this.image,
    this.createdAt,
  });

  // Chuẩn hoá URL ảnh
  static String normalizeUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    return '${AppConstants.baseUrl}/${Uri.encodeFull(path)}';
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;

    final rawImage = json['image'] ?? '';
    final imageUrl = rawImage.isNotEmpty ? normalizeUrl(rawImage) : '';

    return Playlist(
      id: id,
      name: json['name'] ?? '',
      image: imageUrl,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

 
  String get fullImageUrl {
    if (image.isEmpty) return 'assets/default_playlist.png';
    return image;
  }

  @override
  String toString() {
    return 'Playlist{id: $id, name: $name, image: $image, createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Playlist && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
