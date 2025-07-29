import 'song.dart';

class Block {
  final int id;
  final String name;
  final List<Song> songs;

  Block({
    required this.id,
    required this.name,
    required this.songs,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: json['id'],
      name: json['name'],
      songs: (json['songs'] as List<dynamic>?)
          ?.map((songJson) => Song.fromJson(songJson))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }
}
