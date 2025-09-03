class Genre {
  final int id;
  final String name;
  final String description;

  Genre({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };

  @override
  String toString() {
    return 'Genre{id: $id, name: $name, description: $description}';
  }
  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Genre && other.id == id);

}
