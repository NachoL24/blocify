class PlaylistSummary {
  final int id;
  final String name;
  final String description;
  final int songCount;

  PlaylistSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.songCount,
  });

  factory PlaylistSummary.fromJson(Map<String, dynamic> json) {
    final songs = json['songs'] as List<dynamic>? ?? [];
    return PlaylistSummary(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      songCount: songs.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'songCount': songCount,
    };
  }
}
