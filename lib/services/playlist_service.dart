import '../models/playlist.dart';

class PlaylistService {
  static final PlaylistService instance = PlaylistService._internal();
  
  PlaylistService._internal();

  // Mock de la respuesta del endpoint /api/playlists/top
  Future<List<Playlist>> getTopPlaylists() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    
    final mockResponse = [
      {
        "id": 1,
        "name": "Discover Weekly",
        "description": "Tu mezcla semanal personalizada",
        "songs": []
      },
      {
        "id": 2,
        "name": "Release Radar",
        "description": "Nuevos lanzamientos para ti",
        "songs": []
      },
      {
        "id": 3,
        "name": "On Repeat",
        "description": "Las que más escuchas",
        "songs": []
      },
      {
        "id": 4,
        "name": "Top Hits Global",
        "description": "Los éxitos más populares",
        "songs": []
      },
      {
        "id": 5,
        "name": "Chill Vibes",
        "description": "Música relajante",
        "songs": []
      },
      {
        "id": 6,
        "name": "Workout Mix",
        "description": "Energía para entrenar",
        "songs": []
      },
      {
        "id": 7,
        "name": "Indie Rock Hits",
        "description": "Lo mejor del indie rock",
        "songs": []
      },
      {
        "id": 8,
        "name": "Pop Latino",
        "description": "Éxitos del pop latino",
        "songs": []
      },
      {
        "id": 9,
        "name": "Jazz Classics",
        "description": "Clásicos del jazz",
        "songs": []
      },
      {
        "id": 10,
        "name": "Electronic Beats",
        "description": "Los mejores beats electrónicos",
        "songs": []
      }
    ];

    return mockResponse.map((json) => Playlist.fromJson(json)).toList();
  }
}
