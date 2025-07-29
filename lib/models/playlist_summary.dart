class PlaylistSummary {
  final int id;
  final String name;
  final String? description;

  PlaylistSummary({
    required this.id,
    required this.name,
    this.description,
  });

  factory PlaylistSummary.fromJson(Map<String, dynamic> json) {
    return PlaylistSummary(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
