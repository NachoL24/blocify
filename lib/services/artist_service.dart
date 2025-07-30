import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/artist.dart';

class ArtistService {
  static final ArtistService _instance = ArtistService._internal();
  factory ArtistService() => _instance;
  ArtistService._internal();

  static const String _baseUrl = 'http://localhost:8096';
  String? _apiKey;

  void configure(String apiKey) {
    _apiKey = apiKey;
  }

  Future<List<ArtistSummary>> getUserArtists() async {
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

        return List.generate(artists.length, (i) => artists[i].copyWith(songCount: counts[i]));
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
}