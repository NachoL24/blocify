import 'dart:typed_data';

import 'package:blocify/services/jellyfin_service.dart';

class Song {
  final String name;
  final String itemId;
  final String artist;
  final String artistId;
  final String album;
  final String albumId;
  final int duration;
  final String id;
  final String? picture;
  final String? albumPrimaryImageTag;
  final String? container;

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
    this.albumPrimaryImageTag,
    this.container,
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
      id: json['id'].toString(),
      picture: json['picture'],
      albumPrimaryImageTag: json['albumPrimaryImageTag'],
      container: json['container'],
    );
  }
  factory Song.fromJellyfinTrack(JellyfinTrack track, String? pictureUrl) {
    return Song(
      name: track.name,
      itemId: track.id,
      artist: track.primaryArtist,
      artistId: track.artistItems.isNotEmpty ? track.artistItems.first.id : '',
      album: track.albumId != null ? track.albumId! : 'Álbum desconocido',
      albumId: track.albumId ?? '',
      duration: track.duration?.inMilliseconds ?? 0,
      id: track.id,
      picture: pictureUrl,
      albumPrimaryImageTag: track.albumPrimaryImageTag,
      container: track.container,
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
      'picture': picture,
      'albumPrimaryImageTag': albumPrimaryImageTag,
      'container': container,
    };
  }

  /// Convertir Song a JellyfinTrack
  JellyfinTrack toJellyfinTrack() {
    return JellyfinTrack(
      id: itemId,
      name: name,
      albumId: albumId.isNotEmpty ? albumId : null,
      albumPrimaryImageTag: albumPrimaryImageTag,
      albumArtist: artist,
      artists: [artist],
      artistItems: [
        JellyfinArtist(
          id: artistId,
          name: artist,
        )
      ],
      runTimeTicks: duration * 10000, // Convertir de milliseconds a ticks
      container: container,
    );
  }
}
