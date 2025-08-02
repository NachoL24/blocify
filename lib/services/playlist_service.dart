import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/http_service.dart';
import '../models/playlist.dart';
import '../models/playlist_summary.dart';
import '../models/block.dart';
import '../models/song.dart';
import '../services/auth0_service.dart';
import '../config/backend_config.dart';
import 'jellyfin_service.dart';

class PlaylistService {
  static final PlaylistService instance = PlaylistService._internal();
  final HttpService _httpService = HttpService();

  factory PlaylistService() => instance;
  PlaylistService._internal();

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

  Future<Playlist> getPlaylistById(int playlistId) async {
    try {
      final response = await HttpService().get('/api/playlists/$playlistId');
      print('🔍 Response for playlist $playlistId: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('🎯 Full playlist data received:');
        data.forEach((key, value) {
          print('   - $key: ${value.runtimeType}');
        });

        final songs = (data['song'] as List? ?? [])
            .map((track) => Song.fromJson(track))
            .toList();

        final blocks = (data['blocks'] as List? ?? []).map((block) {
          return Block.fromJson(block);
        }).toList();

        return Playlist(
          id: data['id'],
          name: data['name'],
          description: data['description'] ?? '',
          songs: songs,
          blocks: blocks,
        );
      } else {
        throw Exception('Failed to load playlist: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getPlaylistById: $e');
      rethrow;
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

  Future<Block> createBlockInPlaylist({
    required int playlistId,
    required String name,
    String? description,
  }) async {
    try {
      final body = {
        'name': name,
        'description': description ?? '',
      };

      final response = await _httpService.post(
        '/api/playlists/$playlistId/block',
        body: body,
      );

      if (response.statusCode == 201) {
        return Block.fromJson(json.decode(response.body));
      } else if (response.statusCode == 204) {
        return Block(
          id: -1,
          name: name,
          description: description ?? '',
          songs: [],
        );
      }
      throw Exception('Error: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error al crear bloque: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<Block> updateBlock({
    required int blockId,
    required String name,
    String? description,
  }) async {
    try {
      final body = {
        'name': name,
        if (description != null) 'description': description,
      };

      final response = await _httpService.patch(
        '/api/blocks/$blockId',
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Block(
          id: blockId,
          name: name,
          description: description ?? '',
          songs: [],
        );
      }
      throw Exception('Error: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error al actualizar bloque: ${e.toString()}');
    }
  }

  Future<void> deleteBlock({
    required int playlistId,
    required int blockId,
  }) async {
    try {
      final response = await _httpService.delete(
        '/api/playlists/$playlistId/block/$blockId',
      );

      if (response.statusCode != 204) {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar bloque: ${e.toString()}');
    }
  }

  Future<List<Block>> getBlocksByPlaylist(int playlistId) async {
    try {
      final response = await _httpService.get(
        '/api/playlists/$playlistId/blocks',
      );

      if (response.statusCode == 200) {
        final blocksJson = jsonDecode(response.body) as List;
        return blocksJson.map((json) => Block.fromJson(json)).toList();
      }
      throw Exception('Error: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error al obtener bloques: ${e.toString()}');
    }
  }

  Future<void> removeSongFromPlaylist({
    required int playlistId,
    required String songId,
  }) async {
    final url = '/api/playlists/$playlistId/remove?songId=$songId';
    final res = await _httpService.post(url);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Error al quitar canción: ${res.statusCode}');
    }
  }

  Future<void> addSongToBlock({
    required int playlistId,
    required int blockId,
    required String songId,
  }) async {
    final url = '/api/playlists/$playlistId/block/$blockId/add?songId=$songId';
    final res = await _httpService.post(url);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Error al agregar canción al bloque: ${res.statusCode}');
    }
  }

  Future<void> addSongToPlaylist({
    required int playlistId,
    required Song song,
  }) async {
    final url = '/api/playlists/$playlistId/add';
    final res = await _httpService.post(
      url,
      body: song.toJson(),
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Error al añadir canción: ${res.statusCode}');
    }
  }

  Future<void> removeSongFromBlock({
    required int playlistId,
    required int blockId,
    required String songId,
  }) async {
    final url = '/api/playlists/$playlistId/block/$blockId/remove?songId=$songId';
    final res = await _httpService.post(url);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Error al quitar canción del bloque: ${res.statusCode}');
    }
  }

  Future<List<Song>> getBlockSongs({
    required int playlistId,
    required int blockId,
  }) async {
    final response = await HttpService().get('/playlists/$playlistId/blocks/$blockId/songs');
    final jsonData = jsonDecode(response.body) as List;
    return jsonData.map((s) => Song.fromJson(s)).toList();
  }
}
