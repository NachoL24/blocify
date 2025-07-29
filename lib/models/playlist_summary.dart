class PlaylistSummary {
  final int id;
  final String name;

  PlaylistSummary({
    required this.id,
    required this.name,
  });

  factory PlaylistSummary.fromJson(Map<String, dynamic> json) {
    return PlaylistSummary(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
