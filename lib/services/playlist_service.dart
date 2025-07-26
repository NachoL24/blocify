import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../models/playlist.dart';
import '../models/playlist_summary.dart';
import '../models/song.dart';

class PlaylistService {
  static final PlaylistService instance = PlaylistService._internal();
  
  PlaylistService._internal();

  // Mock de la respuesta del endpoint /api/playlists/top
  Future<List<PlaylistSummary>> getTopPlaylists() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    
    final mockResponse = [
      {"id": 1, "name": "Discover Weekly"},
      {"id": 2, "name": "Release Radar"},
      {"id": 3, "name": "On Repeat"},
      {"id": 4, "name": "Top Hits Global"},
      {"id": 5, "name": "Chill Vibes"},
      {"id": 6, "name": "Workout Mix"},
      {"id": 7, "name": "Indie Rock Hits"},
      {"id": 8, "name": "Pop Latino"},
      {"id": 9, "name": "Jazz Classics"},
      {"id": 10, "name": "Electronic Beats"}
    ];

    return mockResponse.map((json) => PlaylistSummary.fromJson(json)).toList();
  }

  // Mock de la respuesta del endpoint /api/playlists/{id}
  Future<Playlist> getPlaylistById(int id) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Cargar la imagen mock
    final Uint8List songPictureBytes = await _loadMockSongPicture();
    
    // Mock de datos de playlist con canciones
    final Map<String, dynamic> mockPlaylistData = {
      "id": id,
      "name": _getPlaylistNameById(id),
      "description": _getPlaylistDescriptionById(id),
      "songs": [
        {
          "name": "La Curiosidad",
          "itemId": "12345-abc",
          "artist": "Jay Wheeler",
          "artistId": "artist-789",
          "album": "Platónicos",
          "albumId": "album-456",
          "duration": 21,
          "id": 2,
          "picture": songPictureBytes.toList()
        },
        {
          "name": "Fiel",
          "itemId": "67890-def",
          "artist": "Los Legendarios",
          "artistId": "artist-123",
          "album": "La Mafia",
          "albumId": "album-789",
          "duration": 18,
          "id": 3,
          "picture": songPictureBytes.toList()
        },
        {
          "name": "Con Altura",
          "itemId": "11111-ghi",
          "artist": "ROSALÍA",
          "artistId": "artist-456",
          "album": "Con Altura",
          "albumId": "album-012",
          "duration": 22,
          "id": 4,
          "picture": songPictureBytes.toList()
        }
      ]
    };

    return Playlist.fromJson(mockPlaylistData);
  }

  // Método para cargar la imagen mock desde assets
  Future<Uint8List> _loadMockSongPicture() async {
    try {
      final ByteData data = await rootBundle.load('lib/services/song-picture.jpeg');
      return data.buffer.asUint8List();
    } catch (e) {
      // Si no se puede cargar la imagen, retornar bytes vacíos
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
