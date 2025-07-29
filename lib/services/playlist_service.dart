import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../models/playlist.dart';
import '../models/playlist_summary.dart';
import '../models/song.dart';
import '../models/block.dart';

class PlaylistService {
  static final PlaylistService instance = PlaylistService._internal();

  PlaylistService._internal();

  
  Future<List<PlaylistSummary>> getTopPlaylists() async {
    
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

  
  Future<List<PlaylistSummary>> getDiscoverPlaylists() async {
    
    await Future.delayed(const Duration(milliseconds: 500));

    final mockResponse = [
      {"id": 1, "name": "New Music Friday"},
      {"id": 2, "name": "Today's Top Hits"},
      {"id": 3, "name": "RapCaviar"},
      {"id": 4, "name": "Hot Country"},
      {"id": 5, "name": "Rock Classics"},
      {"id": 6, "name": "Chill Hits"},
      {"id": 7, "name": "Pop Rising"},
      {"id": 8, "name": "Indie Pop Chillout"},
      {"id": 9, "name": "Acoustic Covers"},
      {"id": 10, "name": "Latin Pop Rising"}
    ];

    return mockResponse.map((json) => PlaylistSummary.fromJson(json)).toList();
  }

  
  Future<List<PlaylistSummary>> getUserPlaylists() async {
    
    await Future.delayed(const Duration(milliseconds: 500));

    final mockResponse = [
      {"id": 1, "name": "My Favorite Songs"},
      {"id": 2, "name": "Chill Beats"},
      {"id": 3, "name": "Workout Playlist"},
      {"id": 4, "name": "Party Hits"},
      {"id": 5, "name": "Indie Discoveries"},
      {"id": 6, "name": "Classic Rock Anthems"},
      {"id": 7, "name": "Pop Perfection"},
      {"id": 8, "name": "Jazz Essentials"},
      {"id": 9, "name": "Electronic Vibes"},
      {"id": 10, "name": "Reggaeton Hits"}
    ];

    return mockResponse.map((json) => PlaylistSummary.fromJson(json)).toList();
  }

  
  Future<Playlist> getPlaylistById(int id) async {
    
    await Future.delayed(const Duration(milliseconds: 300));

    final Uint8List songPictureBytes = await _loadMockSongPicture();

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
      ],
      "blocks": [
        {
          "id": 1,
          "name": "melancolia",
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
              "name": "Melancolía",
              "itemId": "5e8be675d5e30a4c8eb05bc4f43abafe",
              "artist": "Bad Bunny",
              "artistId": "artist-999",
              "album": "YHLQMDLG",
              "albumId": "album-999",
              "duration": 19,
              "id": 5,
              "picture": songPictureBytes.toList()
            }
          ]
        },
        {
          "id": 2,
          "name": "energeticos",
          "songs": [
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
            },
            {
              "name": "Safaera",
              "itemId": "safaera-456",
              "artist": "Bad Bunny",
              "artistId": "artist-999",
              "album": "YHLQMDLG",
              "albumId": "album-999",
              "duration": 29,
              "id": 6,
              "picture": songPictureBytes.toList()
            }
          ]
        },
        {
          "id": 3,
          "name": "romanticas",
          "songs": [
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
              "name": "Dákiti",
              "itemId": "dakiti-789",
              "artist": "Bad Bunny ft. Jhay Cortez",
              "artistId": "artist-999",
              "album": "El Último Tour Del Mundo",
              "albumId": "album-888",
              "duration": 25,
              "id": 7,
              "picture": songPictureBytes.toList()
            }
          ]
        },
        {
          "id": 4,
          "name": "fiesta",
          "songs": [
            {
              "name": "Baila Baila Baila",
              "itemId": "baila-123",
              "artist": "ROSALÍA",
              "artistId": "artist-456",
              "album": "El Mal Querer",
              "albumId": "album-111",
              "duration": 20,
              "id": 8,
              "picture": songPictureBytes.toList()
            },
            {
              "name": "Tusa",
              "itemId": "tusa-456",
              "artist": "Karol G ft. Nicki Minaj",
              "artistId": "artist-222",
              "album": "Tusa",
              "albumId": "album-333",
              "duration": 23,
              "id": 9,
              "picture": songPictureBytes.toList()
            }
          ]
        },
        {
          "id": 5,
          "name": "clasicos",
          "songs": [
            {
              "name": "Livin' la Vida Loca",
              "itemId": "livin-123",
              "artist": "Ricky Martin",
              "artistId": "artist-444",
              "album": "Ricky Martin",
              "albumId": "album-555",
              "duration": 30,
              "id": 10,
              "picture": songPictureBytes.toList()
            },
            {
              "name": "Macarena",
              "itemId": "macarena-456",
              "artist": "Los Del Rio",
              "artistId": "artist-666",
              "album": "A Mover El Esqueleto",
              "albumId": "album-777",
              "duration": 28,
              "id": 11,
              "picture": songPictureBytes.toList()
            }
          ]
        }
      ]
    };

    return Playlist.fromJson(mockPlaylistData);
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
