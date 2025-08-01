import 'song.dart';
import 'block.dart';

class Playlist {
  final int id;
  final String name;
  final String description;
  final List<Song> songs;
  final List<Block> blocks;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.songs,
    required this.blocks,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      songs: (json['songs'] as List<dynamic>?)
              ?.map((songJson) => Song.fromJson(songJson))
              .toList() ??
          [],
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((blockJson) => Block.fromJson(blockJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'songs': songs.map((song) => song.toJson()).toList(),
      'blocks': blocks.map((block) => block.toJson()).toList(),
    };
  }
}
