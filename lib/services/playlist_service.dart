import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/http_service.dart';
import '../models/playlist.dart';
import '../models/playlist_summary.dart';
import '../services/auth0_service.dart';
import '../config/backend_config.dart';

class PlaylistService {
  static final PlaylistService instance = PlaylistService._internal();
  final HttpService _httpService = HttpService();

  factory PlaylistService() => instance;
  PlaylistService._internal();

  // Método configure actualizado para usar BackendConfig
  void configure() {
    print('PlaylistService configurado usando BackendConfig.baseUrl');
  }

  Future<Map<String, dynamic>?> createPlaylist({
    required String name,
    required String description,
  }) async {
    try {
      final auth0Service = Auth0Service.instance;

      if (!auth0Service.isAuthenticated ||
          auth0Service.currentCredentials == null ||
          auth0Service.currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final body = {
        'name': name,
        'description': description,
        'ownerId': auth0Service.currentUser!.id,
      };

      print('🚀 Creando playlist con datos:');
      print('   - Name: $name');
      print('   - Description: $description');
      print('   - Owner ID: ${auth0Service.currentUser!.id}');

      final response = await _httpService.post('/api/playlists', body: body);

      print('📱 Respuesta del servidor:');
      print('   - Status: ${response.statusCode}');
      print('   - Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear playlist: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en createPlaylist: $e');
      throw Exception('Error al crear playlist: $e');
    }
  }

  Future<Map<String, dynamic>?> updatePlaylist({
    required int playlistId,
    required String name,
    required String description,
  }) async {
    try {
      final auth0Service = Auth0Service.instance;

      if (!auth0Service.isAuthenticated ||
          auth0Service.currentCredentials == null ||
          auth0Service.currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final body = {
        'id': playlistId,
        'name': name,
        'description': description,
        'blocks': [],
        'songs': [],
      };

      print('✏️ Actualizando playlist con datos:');
      print('   - ID: $playlistId');
      print('   - Name: $name');
      print('   - Description: $description');

      final response = await _httpService.patch('/api/playlists/$playlistId', body: body);

      print('📱 Respuesta del servidor:');
      print('   - Status: ${response.statusCode}');
      print('   - Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al actualizar playlist: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en updatePlaylist: $e');
      throw Exception('Error al actualizar playlist: $e');
    }
  }

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
      print('🔍 Obteniendo playlists para usuario: $userId');
      final response = await _httpService.get('/api/playlists/user/$userId');

      print('📱 Respuesta getUserPlaylists:');
      print('   - Status: ${response.statusCode}');
      print('   - Body: ${response.body}');

      if (response.statusCode == 200) {
        final playlistsJson = jsonDecode(response.body) as List;
        final playlists = playlistsJson
            .map((json) => PlaylistSummary.fromJson(json))
            .toList();

        print('✅ Playlists obtenidas: ${playlists.length}');
        for (var playlist in playlists) {
          print('   - ${playlist.name} (ID: ${playlist.id})');
        }

        return playlists;
      } else {
        print('❌ Error al obtener playlists: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error en getUserPlaylists: $e');
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
        rethrow;
      }
      throw Exception('Error de conexión al cargar la playlist');
    }
  }

  Future<void> deletePlaylist(int playlistId) async {
    try {
      final auth0Service = Auth0Service.instance;

      if (!auth0Service.isAuthenticated ||
          auth0Service.currentCredentials == null ||
          auth0Service.currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      print('🗑️ Eliminando playlist con ID: $playlistId');

      final response = await _httpService.delete('/api/playlists/$playlistId');

      print('📱 Respuesta del servidor al eliminar:');
      print('   - Status: ${response.statusCode}');
      print('   - Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar playlist: ${response.statusCode}');
      }

    } catch (e) {
      print('❌ Error en deletePlaylist: $e');
      throw Exception('Error al eliminar playlist: $e');
    }
  }
}