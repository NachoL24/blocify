import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class JellyfinService {
  static String get baseUrl =>
      dotenv.env['BASE_JELLYFIN_URL'] ?? 'http://localhost:8096';
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
    if (track.albumId != null) {
      return getImageUrl(track.albumId!);
    }

    if (track.artistItems.isNotEmpty) {
      return getImageUrl(track.artistItems.first.id);
    }

    return getImageUrl(track.id);
  }
}

class JellyfinTrack {
  final String id;
  final String name;
  final String? albumId;
  final List<String> artists;
  final List<JellyfinArtist> artistItems;

  JellyfinTrack({
    required this.id,
    required this.name,
    this.albumId,
    required this.artists,
    required this.artistItems,
  });

  factory JellyfinTrack.fromJson(Map<String, dynamic> json) {
    return JellyfinTrack(
      id: json['Id'] ?? '',
      name: json['Name'] ?? 'Canción sin título',
      albumId: json['AlbumId'],
      artists: List<String>.from(json['Artists'] ?? []),
      artistItems: (json['ArtistItems'] as List<dynamic>? ?? [])
          .map((item) => JellyfinArtist.fromJson(item))
          .toList(),
    );
  }

  String get primaryArtist {
    if (artists.isNotEmpty) {
      return artists.first;
    }
    if (artistItems.isNotEmpty) {
      return artistItems.first.name;
    }
    return 'Artista desconocido';
  }

  String get streamUrl => JellyfinService.getStreamUrl(id);

  String? get imageUrl {
    if (albumId != null) {
      return JellyfinService.getImageUrl(albumId!);
    }
    if (artistItems.isNotEmpty) {
      return JellyfinService.getImageUrl(artistItems.first.id);
    }
    return JellyfinService.getImageUrl(id);
  }
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
