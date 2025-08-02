import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/artist.dart';

class ArtistService {
  static final ArtistService _instance = ArtistService._internal();
  factory ArtistService() => _instance;
  ArtistService._internal();

  // Usamos las variables de entorno correctamente
  static String get _baseUrl => dotenv.env['BASE_JELLYFIN_URL'] ?? 'http://localhost:8096';
  static String get _apiKey => dotenv.env['API_KEY'] ?? '';

  List<ArtistSummary>? _cachedArtists;

  Future<List<ArtistSummary>> getUserArtists({bool forceRefresh = false}) async {
    if (_cachedArtists != null && !forceRefresh) {
      return _cachedArtists!;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Items?IncludeItemTypes=MusicArtist&Recursive=true&api_key=$_apiKey'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['Items'] as List;

        final artists = items.map((json) => ArtistSummary.fromJson(json)).toList();

        // Obtenemos conteo de canciones en paralelo
        final counts = await Future.wait(
            artists.map((a) => _getArtistSongCount(a.id))
        );

        _cachedArtists = List.generate(
            artists.length,
                (i) => artists[i].copyWith(songCount: counts[i])
        );

        return _cachedArtists!;
      } else {
        throw Exception('Failed to load artists: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching artists: $e');
    }
  }

  Future<int> _getArtistSongCount(String artistId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Items?IncludeItemTypes=Audio&Recursive=true&ArtistIds=$artistId&api_key=$_apiKey'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['TotalRecordCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<ArtistSummary>> searchArtists(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Items?IncludeItemTypes=MusicArtist&Recursive=true&SearchTerm=$query&api_key=$_apiKey'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['Items'] as List).map((json) => ArtistSummary.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error searching artists: $e');
    }
  }

  void clearCache() {
    _cachedArtists = null;
  }
}