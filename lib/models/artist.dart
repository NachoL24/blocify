class ArtistSummary {
  final String id;
  final String name;
  final int songCount;

  ArtistSummary({
    required this.id,
    required this.name,
    this.songCount = 0,
  });

  factory ArtistSummary.fromJson(Map<String, dynamic> json) {
    return ArtistSummary(
      id: json['id'] ?? json['Id'],
      name: json['name'] ?? json['Name'],
      songCount: json['songCount'] ?? json['SongCount'] ?? 0,
    );
  }

  ArtistSummary copyWith({
    String? id,
    String? name,
    int? songCount,
  }) {
    return ArtistSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      songCount: songCount ?? this.songCount,
    );
  }

  @override
  String toString() {
    return 'ArtistSummary(id: $id, name: $name, songCount: $songCount)';
  }
}