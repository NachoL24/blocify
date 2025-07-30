import 'dart:convert';
import 'package:blocify/services/http_service.dart';
import '../models/playlist.dart';
import '../models/playlist_summary.dart';
import '../services/auth0_service.dart';

class PlaylistService {
  static final PlaylistService instance = PlaylistService._internal();
  factory PlaylistService() => instance;
  PlaylistService._internal();

  final HttpService _httpService = HttpService();

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

      final response =
          await _httpService.patch('/api/playlists/$playlistId', body: body);

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

  Future<Map<String, dynamic>> getPlaylistReproductionQueue(
    int playlistId, {
    required bool random,
    required bool block,
    int? countBlock,
  }) async {
    try {
      final queryParams = <String, String>{
        'random': random.toString(),
        'block': block.toString(),
      };

      if (block && countBlock != null) {
        queryParams['countBlock'] = countBlock.toString();
      }

      final uri = Uri.parse('/api/reproduction/playlist/$playlistId')
          .replace(queryParameters: queryParams);

      print('🎵 Obteniendo cola de reproducción: ${uri.toString()}');

      final response = await _httpService.get(uri.toString());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Debug mejorado para mostrar información correcta según el modo
        if (data['blocks'] != null) {
          final totalSongs = (data['blocks'] as List).fold<int>(0, (sum, block) => sum + (block['songs'] as List).length);
          print('✅ Cola de reproducción obtenida: ${data['blocks'].length} bloques con $totalSongs canciones total');
        } else if (data['songs'] != null) {
          print('✅ Cola de reproducción obtenida: ${data['songs'].length} canciones');
        } else {
          print('⚠️ Cola de reproducción vacía o formato desconocido');
        }

        return data;
      } else {
        throw Exception('Error al obtener cola de reproducción: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en getPlaylistReproductionQueue: $e');
      throw Exception('Error al obtener cola de reproducción: $e');
    }
  }
}
