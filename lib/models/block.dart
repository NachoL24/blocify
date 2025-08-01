import 'song.dart';

class Block {
  final int id;
  final String name;
  final String? description;
  final List<Song> songs;

  Block({
    required this.id,
    required this.name,
    this.description,
    required this.songs,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      songs: (json['songs'] as List<dynamic>?)
          ?.map((songJson) => Song.fromJson(songJson))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }
}
