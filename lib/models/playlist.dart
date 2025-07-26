class Playlist {
  final int id;
  final String name;
  final String description;
  final List<dynamic> songs;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.songs,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      songs: json['songs'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'songs': songs,
    };
  }
}
