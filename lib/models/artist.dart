class ArtistSummary {
  final String id;
  final String name;
  final int songCount;
  final String? imageUrl;
  final String? overview;

  ArtistSummary({
    required this.id,
    required this.name,
    this.songCount = 0,
    this.imageUrl,
    this.overview,
  });

  factory ArtistSummary.fromJson(Map<String, dynamic> json) {
    return ArtistSummary(
      id: json['Id'] ?? '',
      name: json['Name'] ?? 'Artista desconocido',
      songCount: json['SongCount'] ?? 0,
      imageUrl: json['ImageUrl'] ?? _getImageUrl(json['Id']),
      overview: json['Overview'],
    );
  }

  static String? _getImageUrl(String? artistId) {
    if (artistId == null || artistId.isEmpty) return null;
    return 'http://dorrego-server.brazilsouth.cloudapp.azure.com:9096/Items/$artistId/Images/Primary?maxHeight=300&quality=90';
  }

  ArtistSummary copyWith({
    String? id,
    String? name,
    int? songCount,
    String? imageUrl,
    String? overview,
  }) {
    return ArtistSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      songCount: songCount ?? this.songCount,
      imageUrl: imageUrl ?? this.imageUrl,
      overview: overview ?? this.overview,
    );
  }

  @override
  String toString() {
    return 'ArtistSummary(id: $id, name: $name, songs: $songCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArtistSummary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}