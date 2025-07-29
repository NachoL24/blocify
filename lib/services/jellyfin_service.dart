import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class JellyfinService {
  static String get baseUrl => dotenv.env['API_URL'] ?? 'http://localhost:8096';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  JellyfinService._internal();
  static final JellyfinService instance = JellyfinService._internal();
  factory JellyfinService() => instance;

  static Future<List<JellyfinTrack>> getAllTracks() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/Items?IncludeItemTypes=Audio&Recursive=true&api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['Items'] ?? [];

        return items.map((item) => JellyfinTrack.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tracks: $e');
    }
  }

  Future<List<JellyfinTrack>> get10Tracks() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/Items?IncludeItemTypes=Audio&Recursive=true&Limit=10&api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['Items'] ?? [];

        return items.map((item) => JellyfinTrack.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tracks: $e');
    }
  }

  Future<List<JellyfinTrack>> searchTracks(String query) async {
    try {
      final queryParam = query.split(' ').join('+');
      final response = await http.get(
        Uri.parse(
            '$baseUrl/Items?IncludeItemTypes=Audio&Recursive=true&Limit=10&SearchTerm=$queryParam&api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['Items'] ?? [];

        return items.map((item) => JellyfinTrack.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tracks: $e');
    }
  }

  static String getStreamUrl(String itemId) {
    return '$baseUrl/Items/$itemId/Download?api_key=$apiKey';
  }

  static String getImageUrl(String itemId, {String imageType = 'Primary'}) {
    return '$baseUrl/Items/$itemId/Images/$imageType?api_key=$apiKey';
  }

  static String? getAlbumImageUrl(JellyfinTrack track) {
    if (track.albumId != null && track.albumPrimaryImageTag != null) {
      print("Getting album image for: ${track.albumId}");
      return getImageUrl(track.albumId!);
    }

    if (track.artistItems.isNotEmpty) {
      print("Getting artist image for: ${track.artistItems.first.id}");
      return getImageUrl(track.artistItems.first.id);
    }

    print("Getting track image for: ${track.id}");
    return getImageUrl(track.id);
  }
}

class JellyfinTrack {
  final String id;
  final String name;
  final String? albumId;
  final String? albumPrimaryImageTag;
  final String? albumArtist;
  final List<String> artists;
  final List<JellyfinArtist> artistItems;
  final int? runTimeTicks;
  final String? container;

  JellyfinTrack({
    required this.id,
    required this.name,
    this.albumId,
    this.albumPrimaryImageTag,
    this.albumArtist,
    required this.artists,
    required this.artistItems,
    this.runTimeTicks,
    this.container,
  });

  factory JellyfinTrack.fromJson(Map<String, dynamic> json) {
    return JellyfinTrack(
      id: json['Id'] ?? '',
      name: json['Name'] ?? 'Canción sin título',
      albumId: json['AlbumId'],
      albumPrimaryImageTag: json['AlbumPrimaryImageTag'],
      albumArtist: json['AlbumArtist'],
      artists: List<String>.from(json['Artists'] ?? []),
      artistItems: (json['ArtistItems'] as List<dynamic>? ?? [])
          .map((item) => JellyfinArtist.fromJson(item))
          .toList(),
      runTimeTicks: json['RunTimeTicks'],
      container: json['Container'],
    );
  }

  String get primaryArtist {
    if (albumArtist != null && albumArtist!.isNotEmpty) {
      return albumArtist!;
    }
    if (artists.isNotEmpty) {
      return artists.first;
    }
    if (artistItems.isNotEmpty) {
      return artistItems.first.name;
    }
    return 'Artista desconocido';
  }

  Duration? get duration {
    if (runTimeTicks == null) return null;
    return Duration(microseconds: runTimeTicks! ~/ 10);
  }

  String get streamUrl => JellyfinService.getStreamUrl(id);
  String? get imageUrl => JellyfinService.getAlbumImageUrl(this);
}

class JellyfinArtist {
  final String id;
  final String name;

  JellyfinArtist({
    required this.id,
    required this.name,
  });

  factory JellyfinArtist.fromJson(Map<String, dynamic> json) {
    return JellyfinArtist(
      id: json['Id'] ?? '',
      name: json['Name'] ?? 'Artista desconocido',
    );
  }
}
