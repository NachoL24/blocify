import 'dart:typed_data';
import 'package:blocify/services/jellyfin_service.dart';
import 'package:flutter/services.dart';
import '../models/song.dart';

class SearchService {
  static final SearchService instance = SearchService._internal();
  factory SearchService() => instance;

  SearchService._internal();

  final JellyfinService _jellyfinService = JellyfinService.instance;

  Future<List<Song>> searchSongs(String query) async {
    final List<Song> results = [];
    try {
      if (query.trim().isEmpty) {
        final tracks = await _jellyfinService.get10Tracks();
        for (final track in tracks) {
          print("track: ${track.name}, track.imageUrl: ${track.imageUrl}");
          var song = Song.fromJellyfinTrack(track, track.imageUrl);
          results.add(song);
        }
        return results;
      } else {
        final tracks = await _jellyfinService.searchTracks(query);
        for (final track in tracks) {
          var song = Song.fromJellyfinTrack(track, track.imageUrl);
          results.add(song);
        }
        return results;
      }
    } catch (e) {
      print('Error searching songs: $e');
      return [];
    }
  }

  Future<Uint8List> _loadMockSongPicture() async {
    try {
      final ByteData data =
          await rootBundle.load('lib/services/song-picture.jpeg');
      return data.buffer.asUint8List();
    } catch (e) {
      print('Error loading song picture: $e');
      return Uint8List(0);
    }
  }
}
