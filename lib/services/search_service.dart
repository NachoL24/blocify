import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../models/song.dart';

class SearchService {
  static final SearchService instance = SearchService._internal();
  
  SearchService._internal();

  // Mock de la respuesta del endpoint /api/search/songs
  Future<List<Song>> searchSongs(String query) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Cargar la imagen mock
    final Uint8List songPictureBytes = await _loadMockSongPicture();
    
    // Mock de canciones para búsqueda
    final allSongs = [
      {
        "name": "La Curiosidad",
        "itemId": "12345-abc",
        "artist": "Jay Wheeler",
        "artistId": "artist-789",
        "album": "Platónicos",
        "albumId": "album-456",
        "duration": 21,
        "id": 1,
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
        "id": 2,
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
        "id": 3,
        "picture": songPictureBytes.toList()
      },
      {
        "name": "Melancolía",
        "itemId": "melancolia-123",
        "artist": "Bad Bunny",
        "artistId": "artist-999",
        "album": "YHLQMDLG",
        "albumId": "album-999",
        "duration": 19,
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
        "id": 5,
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
        "id": 6,
        "picture": songPictureBytes.toList()
      },
      {
        "name": "Tití Me Preguntó",
        "itemId": "titi-012",
        "artist": "Bad Bunny",
        "artistId": "artist-999",
        "album": "Un Verano Sin Ti",
        "albumId": "album-777",
        "duration": 24,
        "id": 7,
        "picture": songPictureBytes.toList()
      },
      {
        "name": "Quevedo: Bzrp Music Sessions",
        "itemId": "bzrp-345",
        "artist": "Bizarrap, Quevedo",
        "artistId": "artist-111",
        "album": "Bzrp Music Sessions",
        "albumId": "album-111",
        "duration": 20,
        "id": 8,
        "picture": songPictureBytes.toList()
      },
      {
        "name": "As It Was",
        "itemId": "asitwas-678",
        "artist": "Harry Styles",
        "artistId": "artist-222",
        "album": "Harry's House",
        "albumId": "album-222",
        "duration": 27,
        "id": 9,
        "picture": songPictureBytes.toList()
      },
      {
        "name": "Stay",
        "itemId": "stay-901",
        "artist": "The Kid LAROI & Justin Bieber",
        "artistId": "artist-333",
        "album": "Stay",
        "albumId": "album-333",
        "duration": 23,
        "id": 10,
        "picture": songPictureBytes.toList()
      },
    ];

    // Filtrar canciones que coincidan con la búsqueda
    final filteredSongs = allSongs.where((songJson) {
      final songName = songJson['name'] as String;
      final artistName = songJson['artist'] as String;
      final albumName = songJson['album'] as String;
      
      return songName.toLowerCase().contains(query.toLowerCase()) ||
             artistName.toLowerCase().contains(query.toLowerCase()) ||
             albumName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return filteredSongs.map((json) => Song.fromJson(json)).toList();
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
}
