import 'dart:convert';
import 'dart:typed_data';
import 'package:blocify/services/http_service.dart';
import 'package:flutter/services.dart';
import '../models/playlist.dart';
import '../models/playlist_summary.dart';
import '../models/song.dart';
import '../models/block.dart';

class PlaylistService {
  static final PlaylistService instance = PlaylistService._internal();
  factory PlaylistService() => instance;
  PlaylistService._internal();

  final HttpService _httpService = HttpService();

  Future<List<PlaylistSummary>> getTopPlaylists() async {
    try {
      final response = await _httpService.get('/api/playlists/top');
      if (response.statusCode == 200) {
        final playlistsJson = jsonDecode(response.body) as List;
        return playlistsJson
            .map((json) => PlaylistSummary.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<PlaylistSummary>> getDiscoverPlaylists() async {
    try {
      final response = await _httpService.get('/api/playlists/discover');
      if (response.statusCode == 200) {
        final playlistsJson = [jsonDecode(response.body)];
        return playlistsJson
            .map((json) => PlaylistSummary.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<PlaylistSummary>> getUserPlaylists(String userId) async {
    try {
      final response = await _httpService.get('/api/playlists/user/$userId');
      if (response.statusCode == 200) {
        final playlistsJson = jsonDecode(response.body) as List;
        return playlistsJson
            .map((json) => PlaylistSummary.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Playlist> getPlaylistById(int id) async {
    try {
      final response = await _httpService.get('/api/playlists/$id');
      if (response.statusCode == 200) {
        return Playlist.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al cargar la playlist: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow; // Re-lanzar la excepción para que la pantalla la maneje
      }
      throw Exception('Error de conexión al cargar la playlist');
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

  String _getPlaylistNameById(int id) {
    final names = {
      1: "Discover Weekly",
      2: "Release Radar",
      3: "On Repeat",
      4: "Top Hits Global",
      5: "Chill Vibes",
      6: "Workout Mix",
      7: "Indie Rock Hits",
      8: "Pop Latino",
      9: "Jazz Classics",
      10: "Electronic Beats"
    };
    return names[id] ?? "Playlist $id";
  }

  String _getPlaylistDescriptionById(int id) {
    final descriptions = {
      1: "Tu mezcla semanal personalizada",
      2: "Nuevos lanzamientos para ti",
      3: "Las que más escuchas",
      4: "Los éxitos más populares",
      5: "Música relajante",
      6: "Energía para entrenar",
      7: "Lo mejor del indie rock",
      8: "Éxitos del pop latino",
      9: "Clásicos del jazz",
      10: "Los mejores beats electrónicos"
    };
    return descriptions[id] ?? "Descripción de la playlist $id";
  }
}
