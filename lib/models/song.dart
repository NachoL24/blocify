import 'dart:typed_data';

class Song {
  final String name;
  final String itemId;
  final String artist;
  final String artistId;
  final String album;
  final String albumId;
  final int duration;
  final int id;
  final Uint8List? picture;

  Song({
    required this.name,
    required this.itemId,
    required this.artist,
    required this.artistId,
    required this.album,
    required this.albumId,
    required this.duration,
    required this.id,
    this.picture,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      name: json['name'],
      itemId: json['itemId'],
      artist: json['artist'],
      artistId: json['artistId'],
      album: json['album'],
      albumId: json['albumId'],
      duration: json['duration'],
      id: json['id'],
      picture: json['picture'] != null ? Uint8List.fromList(List<int>.from(json['picture'])) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'itemId': itemId,
      'artist': artist,
      'artistId': artistId,
      'album': album,
      'albumId': albumId,
      'duration': duration,
      'id': id,
      'picture': picture?.toList(),
    };
  }
}
