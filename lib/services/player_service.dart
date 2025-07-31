import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'jellyfin_service.dart';
import 'playlist_service.dart';

class PlayerService extends ChangeNotifier {
  static final PlayerService _instance = PlayerService._internal();
  static PlayerService get instance => _instance;

  PlayerService._internal() {
    // Listen to the audio player's playing state to keep our state in sync
    _player.playingStream.listen((playing) {
      if (_isPlaying != playing) {
        _isPlaying = playing;
        notifyListeners();
      }
    });

    // Escuchar cuando una canción termina para manejar la lógica de loop
    _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _handleSongCompletion();
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();

  JellyfinTrack? _currentTrack;
  bool _isPlaying = false;
  bool _isPlayerVisible = false;
  List<JellyfinTrack> _playlist = [];
  int _currentTrackIndex = -1;
  bool _isRandomMode = false;
  bool _isBlockMode = false;
  int? _currentPlaylistId;
  List<JellyfinTrack> _originalQueue = [];

  // Nuevas propiedades para manejar bloques
  List<Map<String, dynamic>> _blocks = [];
  int _currentBlockIndex = 0;
  int _currentSongInBlockIndex = 0;

  // Estados de loop: 0=desactivado, 1=lista completa, 2=bloque/canción actual, 3=canción sola (solo en modo blocks)
  int _loopMode = 0;

  AudioPlayer get player => _player;
  JellyfinTrack? get currentTrack => _currentTrack;
  String? get currentSongTitle => _currentTrack?.name;
  String? get currentArtist => _currentTrack?.primaryArtist;
  String? get currentAlbumArt => _currentTrack?.imageUrl;
  String? get currentAudioUrl => _currentTrack?.streamUrl;
  bool get isPlaying => _isPlaying;
  bool get isPlayerVisible => _isPlayerVisible;
  bool get hasSong => _currentTrack != null;
  List<JellyfinTrack> get playlist => _playlist;
  int get currentTrackIndex => _currentTrackIndex;
  bool get hasNext => _currentTrackIndex < _playlist.length - 1;
  bool get hasPrevious => _currentTrackIndex > 0;
  bool get isRandomMode => _isRandomMode;
  bool get isBlockMode => _isBlockMode;
  int? get currentPlaylistId => _currentPlaylistId;
  int get loopMode => _loopMode;

  // Nuevos getters para bloques
  List<Map<String, dynamic>> get blocks => _blocks;
  int get currentBlockIndex => _currentBlockIndex;
  bool get hasNextBlock => _currentBlockIndex < _blocks.length - 1;
  bool get hasPreviousBlock => _currentBlockIndex > 0;

  // Debug methods to track playlist state
  void logPlaylistState() {
    debugPrint('=== Playlist State ===');
    debugPrint('Current track: ${_currentTrack?.name}');
    debugPrint('Current index: $_currentTrackIndex');
    debugPrint('Playlist length: ${_playlist.length}');
    debugPrint('Has next: $hasNext');
    debugPrint('Has previous: $hasPrevious');
    debugPrint('Playlist tracks: ${_playlist.map((t) => t.name).join(", ")}');
    debugPrint('=====================');
  }

  Stream<bool> get playingStream => _player.playingStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Future<void> playJellyfinTrack(JellyfinTrack track,
      {List<JellyfinTrack>? playlist, int? index}) async {
    try {
      // Configurar el track ANTES de cualquier operación asíncrona
      _currentTrack = track;
      _isPlayerVisible = true;

      if (playlist != null) {
        print('Playing from provided playlist with track: ${track.name}');
        print('playlist: ${playlist.map((t) => t.name).join(", ")}');
        _playlist = playlist;
        _currentTrackIndex = index ?? playlist.indexOf(track);
      } else {
        _playlist = [track];
        _currentTrackIndex = 0;
      }

      // Notificar inmediatamente que tenemos una canción cargada
      notifyListeners();

      debugPrint('🎵 About to play track: ${track.name}');
      logPlaylistState();

      await _player.setUrl(track.streamUrl);
      await _player.play();

      // _isPlaying state will be updated automatically by the stream listener
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing track: $e');
    }
  }

  Future<void> playSong({
    required String audioUrl,
    required String songTitle,
    String? artist,
    String? albumArt,
  }) async {
    final tempTrack = JellyfinTrack(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      name: songTitle,
      artists: artist != null ? [artist] : [],
      artistItems: [],
    );

    await playJellyfinTrack(tempTrack);
  }

  Future<void> playNext() async {
    debugPrint('🎵 playNext() called');

    if (_isBlockMode && _blocks.isNotEmpty) {
      // Si estamos en modo blocks, manejar la navegación entre bloques
      if (_currentSongInBlockIndex < _playlist.length - 1) {
        // Hay más canciones en el bloque actual
        _currentSongInBlockIndex++;
        _currentTrackIndex++;
        final nextTrack = _playlist[_currentTrackIndex];
        _currentTrack = nextTrack;

        debugPrint('🔲 Siguiente canción en el bloque: ${nextTrack.name}');

        notifyListeners();

        try {
          await _player.setUrl(nextTrack.streamUrl);
          await _player.play();
          notifyListeners();
        } catch (e) {
          debugPrint('Error playing next track: $e');
        }
      } else if (hasNextBlock) {
        // Pasar al siguiente bloque
        await _moveToNextBlock();
      } else {
        debugPrint('🔲 No hay más bloques disponibles');
      }
    } else {
      // Comportamiento normal sin bloques
      if (hasNext) {
        _currentTrackIndex++;
        final nextTrack = _playlist[_currentTrackIndex];
        _currentTrack = nextTrack;
        _isPlayerVisible = true;

        debugPrint('🎵 Moving to next track: ${nextTrack.name}');

        if (_currentPlaylistId != null) {
          _removeCurrentSongFromQueue();
        }

        notifyListeners();

        try {
          await _player.setUrl(nextTrack.streamUrl);
          await _player.play();
          notifyListeners();
        } catch (e) {
          debugPrint('Error playing next track: $e');
        }
      } else {
        debugPrint('🎵 No next track available');
      }
    }
  }

  Future<void> playPrevious() async {
    debugPrint('🎵 playPrevious() called');
    logPlaylistState();

    if (hasPrevious) {
      _currentTrackIndex--;

      // Si estamos en modo blocks, también actualizar el índice del bloque
      if (_isBlockMode && _blocks.isNotEmpty) {
        _currentSongInBlockIndex--;
        debugPrint('🔲 Retrocediendo en el bloque: nueva posición $_currentSongInBlockIndex');
      }

      final previousTrack = _playlist[_currentTrackIndex];
      _currentTrack = previousTrack;
      _isPlayerVisible = true;

      debugPrint('🎵 Moving to previous track: ${previousTrack.name}');
      notifyListeners(); // Notificar antes de la operación asíncrona

      try {
        await _player.setUrl(previousTrack.streamUrl);
        await _player.play();
        notifyListeners(); // Notificar después también
        logPlaylistState();
      } catch (e) {
        debugPrint('Error playing previous track: $e');
      }
    } else {
      debugPrint('🎵 No previous track available');
    }
  }

  Future<void> pause() async {
    await _player.pause();
    // _isPlaying state will be updated automatically by the stream listener
  }

  Future<void> play() async {
    await _player.play();
    // _isPlaying state will be updated automatically by the stream listener
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> stop() async {
    await _player.stop();
    _currentTrack = null;
    _playlist.clear();
    _currentTrackIndex = -1;
    // _isPlaying will be updated automatically by the stream listener
    _isPlayerVisible = false;
    notifyListeners();
  }

  void hideMiniPlayer() {
    _isPlayerVisible = false;
    notifyListeners();
  }

  void showMiniPlayer() {
    if (hasSong) {
      _isPlayerVisible = true;
      notifyListeners();
    }
  }

  Future<List<JellyfinTrack>> loadJellyfinTracks() async {
    try {
      return await JellyfinService.getAllTracks();
    } catch (e) {
      debugPrint('Error loading Jellyfin tracks: $e');
      return [];
    }
  }

  // Método para reproducir desde una playlist usando la cola del backend
  Future<void> playFromPlaylist(int playlistId, String songId) async {
    try {
      debugPrint('🎵 Reproduciendo desde playlist $playlistId, canción $songId');

      // Obtener la cola de reproducción del backend
      final queueData = await PlaylistService.instance.getPlaylistReproductionQueue(
        playlistId,
        random: _isRandomMode,
        block: _isBlockMode, // Usar el modo blocks actual
      );

      // Convertir las canciones del backend a JellyfinTrack
      List<dynamic> songs = [];
      if (_isBlockMode && queueData['blocks'] != null && queueData['blocks'].isNotEmpty) {
        // Si está en modo blocks, extraer canciones del primer bloque
        final firstBlock = queueData['blocks'][0];
        songs = firstBlock['songs'] as List<dynamic>;
      } else if (queueData['songs'] != null) {
        // Si no está en modo blocks, usar las canciones directamente
        songs = queueData['songs'] as List<dynamic>;
      }

      final tracks = songs.map((songJson) => _songToJellyfinTrack(songJson)).toList();

      if (tracks.isEmpty) {
        throw Exception('No hay canciones en la cola de reproducción');
      }

      // Encontrar el índice de la canción que se quiere reproducir
      int startIndex = tracks.indexWhere((track) => track.id == songId);
      if (startIndex == -1) {
        startIndex = 0; // Si no se encuentra, empezar por la primera
      }

      // Configurar la cola y el estado
      _playlist = tracks;
      _originalQueue = List.from(tracks);
      _currentPlaylistId = playlistId;
      _currentTrackIndex = startIndex;
      _currentTrack = tracks[startIndex];
      _isPlayerVisible = true;

      debugPrint('🎵 Cola configurada con ${tracks.length} canciones, empezando en índice $startIndex');

      // Solo eliminar la canción actual de la cola si el modo random está activado
      if (_isRandomMode) {
        _removeCurrentSongFromQueue();
      }

      // Notificar antes de la operación asíncrona
      notifyListeners();

      // Reproducir la canción
      await _player.setUrl(_currentTrack!.streamUrl);
      await _player.play();

      notifyListeners();
      logPlaylistState();
    } catch (e) {
      debugPrint('❌ Error reproduciendo desde playlist: $e');
      throw Exception('Error al reproducir desde playlist: $e');
    }
  }

  // Método para reproducir desde un bloque específico
  Future<void> playFromBlock(int playlistId, int blockId, String songId) async {
    try {
      debugPrint('🔲 Reproduciendo desde playlist $playlistId, bloque $blockId, canción $songId');

      // Obtener la cola de reproducción del backend
      final queueData = await PlaylistService.instance.getPlaylistReproductionQueue(
        playlistId,
        random: _isRandomMode,
        block: _isBlockMode,
      );

      if (_isBlockMode && queueData['blocks'] != null) {
        // Guardar todos los bloques
        _blocks = List<Map<String, dynamic>>.from(queueData['blocks']);

        // Encontrar el bloque específico
        int blockIndex = _blocks.indexWhere((block) => block['id'] == blockId);
        if (blockIndex == -1) blockIndex = 0;

        _currentBlockIndex = blockIndex;

        // Extraer canciones del bloque actual
        final currentBlock = _blocks[_currentBlockIndex];
        final songs = currentBlock['songs'] as List<dynamic>;
        final tracks = songs.map((songJson) => _songToJellyfinTrack(songJson)).toList();

        // Encontrar el índice de la canción específica
        int songIndex = tracks.indexWhere((track) => track.id == songId);
        if (songIndex == -1) songIndex = 0;

        _currentSongInBlockIndex = songIndex;
        _playlist = tracks;
        _currentTrackIndex = songIndex;
        _currentTrack = tracks[songIndex];
        _currentPlaylistId = playlistId;
        _isPlayerVisible = true;

        debugPrint('🔲 Bloque $blockIndex cargado con ${tracks.length} canciones, empezando en canción $songIndex');

        notifyListeners();

        await _player.setUrl(_currentTrack!.streamUrl);
        await _player.play();

        notifyListeners();
      } else {
        // Fallback al método normal si no hay bloques
        await playFromPlaylist(playlistId, songId);
      }
    } catch (e) {
      debugPrint('❌ Error reproduciendo desde bloque: $e');
      throw Exception('Error al reproducir desde bloque: $e');
    }
  }

  // Convertir una canción del backend a JellyfinTrack
  JellyfinTrack _songToJellyfinTrack(Map<String, dynamic> songJson) {
    // El itemId del backend es el ID de Jellyfin que necesitamos
    final jellyfinId = songJson['itemId'] ?? songJson['id'].toString();

    return JellyfinTrack(
      id: jellyfinId, // Usar el itemId que viene del backend
      name: songJson['name'] ?? 'Canción sin nombre',
      artists: [songJson['artist'] ?? 'Artista desconocido'],
      artistItems: [], // Se puede expandir si es necesario
      albumId: songJson['albumId'], // Usar el albumId del backend para las imágenes
    );
  }

  // Eliminar la canción actual de la cola para evitar duplicados
  void _removeCurrentSongFromQueue() {
    if (_currentTrack != null && _originalQueue.isNotEmpty) {
      _originalQueue.removeWhere((track) => track.id == _currentTrack!.id);
      debugPrint('🎵 Canción actual eliminada de la cola. Cola restante: ${_originalQueue.length} canciones');
    }
  }

  void setRandomMode(bool isEnabled) {
    _isRandomMode = isEnabled;

    // Si hay una playlist activa del backend, regenerar la cola con el nuevo modo
    if (_currentPlaylistId != null && _currentTrack != null) {
      _regeneratePlaylistQueue();
    }

    notifyListeners();
  }

  void setBlockMode(bool isEnabled) {
    _isBlockMode = isEnabled;

    // Si hay una playlist activa del backend, regenerar la cola con el nuevo modo
    if (_currentPlaylistId != null && _currentTrack != null) {
      _regeneratePlaylistQueue();
    }

    notifyListeners();
  }

  // Método para cambiar entre estados de loop
  void toggleLoopMode() {
    if (_isBlockMode) {
      // En modo blocks: 0 -> 1 -> 2 -> 3 -> 0
      _loopMode = (_loopMode + 1) % 4;
    } else {
      // En modo playlist normal: 0 -> 1 -> 2 -> 0 (sin estado 3)
      _loopMode = (_loopMode + 1) % 3;
      if (_loopMode == 3) _loopMode = 0; // Asegurar que no llegue a 3 en modo playlist
    }

    debugPrint('🔁 Loop mode cambiado a: $_loopMode');
    notifyListeners();
  }

  // Getter para obtener el icono y descripción del estado actual de loop
  IconData get loopIcon {
    switch (_loopMode) {
      case 0:
        return Icons.repeat_outlined; // Desactivado
      case 1:
        return Icons.repeat; // Loop lista completa
      case 2:
        return _isBlockMode ? Icons.view_module_outlined : Icons.repeat_one; // Loop bloque (modo blocks) / canción (modo normal)
      case 3:
        return Icons.audiotrack; // Loop canción sola (solo blocks) - icono de pista de audio
      default:
        return Icons.repeat_outlined;
    }
  }

  String get loopDescription {
    if (_isBlockMode) {
      switch (_loopMode) {
        case 0:
          return 'Sin repetición';
        case 1:
          return 'Repetir todos los bloques';
        case 2:
          return 'Repetir bloque actual';
        case 3:
          return 'Repetir canción actual';
        default:
          return 'Sin repetición';
      }
    } else {
      switch (_loopMode) {
        case 0:
          return 'Sin repetición';
        case 1:
          return 'Repetir playlist';
        case 2:
          return 'Repetir canción actual';
        default:
          return 'Sin repetición';
      }
    }
  }

  // Método para reproducir playlist completa (desde el botón play en playlist detail)
  Future<void> playEntirePlaylist(int playlistId) async {
    try {
      debugPrint('🎵 Reproduciendo playlist completa $playlistId');

      // Obtener la cola de reproducción del backend
      final queueData = await PlaylistService.instance.getPlaylistReproductionQueue(
        playlistId,
        random: _isRandomMode,
        block: _isBlockMode,
      );

      if (_isBlockMode && queueData['blocks'] != null && queueData['blocks'].isNotEmpty) {
        // Si está en modo blocks, guardar todos los bloques y cargar el primer bloque
        _blocks = List<Map<String, dynamic>>.from(queueData['blocks']);
        _currentBlockIndex = 0;
        _currentSongInBlockIndex = 0;

        debugPrint('🔲 Modo blocks activado: ${_blocks.length} bloques disponibles');

        final firstBlock = _blocks[0];
        final songs = firstBlock['songs'] as List<dynamic>;
        final tracks = songs.map((songJson) => _songToJellyfinTrack(songJson)).toList();

        if (tracks.isEmpty) {
          throw Exception('No hay canciones en el primer bloque');
        }

        // Configurar la cola y el estado
        _playlist = tracks;
        _originalQueue = List.from(tracks);
        _currentPlaylistId = playlistId;
        _currentTrackIndex = 0;
        _currentTrack = tracks[0];
        _isPlayerVisible = true;

        debugPrint('🔲 Primer bloque "${firstBlock['name']}" cargado con ${tracks.length} canciones');

      } else if (queueData['songs'] != null) {
        // Si no está en modo blocks, usar las canciones directamente
        final songs = queueData['songs'] as List<dynamic>;
        final tracks = songs.map((songJson) => _songToJellyfinTrack(songJson)).toList();

        if (tracks.isEmpty) {
          throw Exception('No hay canciones en la playlist');
        }

        // Configurar la cola y el estado
        _playlist = tracks;
        _originalQueue = List.from(tracks);
        _currentPlaylistId = playlistId;
        _currentTrackIndex = 0;
        _currentTrack = tracks[0];
        _isPlayerVisible = true;

        debugPrint('🎵 Playlist completa configurada con ${tracks.length} canciones');
      } else {
        throw Exception('No se encontraron canciones en la respuesta del backend');
      }

      // Solo eliminar la canción actual de la cola si el modo random está activado
      if (_isRandomMode) {
        _removeCurrentSongFromQueue();
      }

      // Notificar antes de la operación asíncrona
      notifyListeners();

      // Reproducir la primera canción
      await _player.setUrl(_currentTrack!.streamUrl);
      await _player.play();

      notifyListeners();
      logPlaylistState();
    } catch (e) {
      debugPrint('❌ Error reproduciendo playlist completa: $e');
      throw Exception('Error al reproducir playlist: $e');
    }
  }

  // Método para pasar al siguiente bloque automáticamente
  Future<void> _moveToNextBlock() async {
    if (!hasNextBlock) return;

    try {
      _currentBlockIndex++;
      _currentSongInBlockIndex = 0;

      final nextBlock = _blocks[_currentBlockIndex];
      final songs = nextBlock['songs'] as List<dynamic>;
      final tracks = songs.map((songJson) => _songToJellyfinTrack(songJson)).toList();

      if (tracks.isNotEmpty) {
        _playlist = tracks;
        _currentTrackIndex = 0;
        _currentTrack = tracks[0];

        debugPrint('🔲 Avanzando automáticamente al bloque ${nextBlock['name']} con ${tracks.length} canciones');

        notifyListeners();

        await _player.setUrl(_currentTrack!.streamUrl);
        await _player.play();

        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error avanzando al siguiente bloque: $e');
    }
  }

  // Método mejorado para ir al bloque anterior
  Future<void> previousBlock() async {
    if (_currentPlaylistId == null || !_isBlockMode || !hasPreviousBlock) return;

    try {
      _currentBlockIndex--;
      _currentSongInBlockIndex = 0;

      final previousBlock = _blocks[_currentBlockIndex];
      final songs = previousBlock['songs'] as List<dynamic>;
      final tracks = songs.map((songJson) => _songToJellyfinTrack(songJson)).toList();

      if (tracks.isNotEmpty) {
        _playlist = tracks;
        _currentTrackIndex = 0;
        _currentTrack = tracks[0];

        debugPrint('🔲 Retrocediendo al bloque ${previousBlock['name']} con ${tracks.length} canciones');

        notifyListeners();

        await _player.setUrl(_currentTrack!.streamUrl);
        await _player.play();

        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error retrocediendo al bloque anterior: $e');
    }
  }

  // Método mejorado para ir al siguiente bloque manualmente
  Future<void> nextBlock() async {
    if (_currentPlaylistId == null || !_isBlockMode || !hasNextBlock) return;

    try {
      _currentBlockIndex++;
      _currentSongInBlockIndex = 0;

      final nextBlock = _blocks[_currentBlockIndex];
      final songs = nextBlock['songs'] as List<dynamic>;
      final tracks = songs.map((songJson) => _songToJellyfinTrack(songJson)).toList();

      if (tracks.isNotEmpty) {
        _playlist = tracks;
        _currentTrackIndex = 0;
        _currentTrack = tracks[0];

        debugPrint('🔲 Avanzando manualmente al bloque ${nextBlock['name']} con ${tracks.length} canciones');

        notifyListeners();

        await _player.setUrl(_currentTrack!.streamUrl);
        await _player.play();

        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error avanzando al siguiente bloque: $e');
    }
  }

  // Método para obtener el nombre del bloque actual
  String? get currentBlockName {
    if (_isBlockMode && _blocks.isNotEmpty && _currentBlockIndex < _blocks.length) {
      return _blocks[_currentBlockIndex]['name'];
    }
    return null;
  }

  // Regenerar la cola de reproducción cuando cambia el modo aleatorio o de bloques
  Future<void> _regeneratePlaylistQueue() async {
    if (_currentPlaylistId == null || _currentTrack == null) return;

    try {
      debugPrint('🔀 Regenerando cola con random=$_isRandomMode, block=$_isBlockMode para playlist $_currentPlaylistId');

      // Guardar la canción actual para encontrarla en la nueva cola
      final currentSongId = _currentTrack!.id;

      // Obtener nueva cola del backend con el modo aleatorio y blocks actualizado
      final queueData = await PlaylistService.instance.getPlaylistReproductionQueue(
        _currentPlaylistId!,
        random: _isRandomMode,
        block: _isBlockMode,
      );

      if (_isBlockMode && queueData['blocks'] != null) {
        // Si estamos en modo blocks, guardar todos los bloques
        _blocks = List<Map<String, dynamic>>.from(queueData['blocks']);

        // Encontrar en qué bloque está la canción actual
        int foundBlockIndex = -1;
        int foundSongIndex = -1;
        List<JellyfinTrack> foundBlockTracks = [];

        for (int blockIndex = 0; blockIndex < _blocks.length; blockIndex++) {
          final block = _blocks[blockIndex];
          final songs = block['songs'] as List<dynamic>;
          final tracks = songs.map((songJson) => _songToJellyfinTrack(songJson)).toList();

          int songIndex = tracks.indexWhere((track) => track.id == currentSongId);
          if (songIndex != -1) {
            foundBlockIndex = blockIndex;
            foundSongIndex = songIndex;
            foundBlockTracks = tracks;
            break;
          }
        }

        if (foundBlockIndex != -1) {
          // Encontramos la canción en un bloque específico
          _currentBlockIndex = foundBlockIndex;

          if (_isRandomMode) {
            // En modo random: mover la canción actual al inicio del bloque
            final currentTrack = foundBlockTracks[foundSongIndex];

            // Remover la canción de su posición actual
            foundBlockTracks.removeAt(foundSongIndex);

            // Insertarla al inicio
            foundBlockTracks.insert(0, currentTrack);

            // Configurar índices
            _currentSongInBlockIndex = 0;
            _currentTrackIndex = 0;
            _currentTrack = currentTrack;

            debugPrint('🔀 Modo random activado: canción movida al inicio del bloque $foundBlockIndex');
          } else {
            // En modo lineal: mantener la posición original
            _currentSongInBlockIndex = foundSongIndex;
            _currentTrackIndex = foundSongIndex;
            _currentTrack = foundBlockTracks[foundSongIndex];

            debugPrint('🔀 Modo lineal: canción mantenida en posición $foundSongIndex del bloque $foundBlockIndex');
          }

          _playlist = foundBlockTracks;
          _originalQueue = List.from(foundBlockTracks);

        } else {
          // Si no encontramos la canción, usar el primer bloque
          _currentBlockIndex = 0;
          _currentSongInBlockIndex = 0;

          final firstBlock = _blocks[0];
          final songs = firstBlock['songs'] as List<dynamic>;
          final newTracks = songs.map((songJson) => _songToJellyfinTrack(songJson)).toList();

          if (newTracks.isNotEmpty) {
            _playlist = newTracks;
            _originalQueue = List.from(newTracks);
            _currentTrackIndex = 0;
            _currentTrack = newTracks[0];
          }

          debugPrint('🔀 Canción no encontrada, usando primer bloque');
        }

        debugPrint('🔀 Nueva cola generada con bloques: ${_blocks.length} bloques, bloque actual ${_currentBlockIndex} con ${_playlist.length} canciones');

      } else if (queueData['songs'] != null) {
        // Si no está en modo blocks, usar las canciones directamente
        final songs = queueData['songs'] as List<dynamic>;
        final newTracks = songs.map((songJson) => _songToJellyfinTrack(songJson)).toList();

        if (newTracks.isNotEmpty) {
          _playlist = newTracks;
          _originalQueue = List.from(newTracks);

          // Buscar la canción actual en la nueva cola
          int currentSongIndex = newTracks.indexWhere((track) => track.id == currentSongId);
          if (currentSongIndex != -1) {
            _currentTrackIndex = currentSongIndex;
            _currentTrack = newTracks[currentSongIndex];
          } else {
            _currentTrackIndex = 0;
            _currentTrack = newTracks[0];
          }

          // Solo eliminar la canción actual de la cola si el modo random está activado
          if (_isRandomMode) {
            _removeCurrentSongFromQueue();
          }

          debugPrint('🔀 Nueva cola generada con ${newTracks.length} canciones, canción actual en índice $_currentTrackIndex');
        }
      } else {
        debugPrint('🔀 La nueva cola está vacía');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error regenerando cola: $e');
    }
  }

  // Manejar la lógica cuando una canción termina
  void _handleSongCompletion() async {
    debugPrint('🎵 Canción terminada. Loop mode: $_loopMode, Block mode: $_isBlockMode');

    switch (_loopMode) {
      case 0: // Desactivado
        if (_isBlockMode) {
          // En modo blocks: cuando termina el bloque se pausa
          if (_currentSongInBlockIndex < _playlist.length - 1) {
            // Hay más canciones en el bloque actual
            await playNext();
          } else {
            // Se terminó el bloque, pausar
            debugPrint('🔲 Bloque terminado - pausando reproducción');
            await pause();
          }
        } else {
          // En modo playlist: cuando termina la playlist se pausa
          if (hasNext) {
            await playNext();
          } else {
            debugPrint('🎵 Playlist terminada - pausando reproducción');
            await pause();
          }
        }
        break;

      case 1: // Loop lista completa
        if (_isBlockMode) {
          // En modo blocks: loop todos los bloques
          if (_currentSongInBlockIndex < _playlist.length - 1) {
            // Hay más canciones en el bloque actual
            await playNext();
          } else if (hasNextBlock) {
            // Pasar al siguiente bloque
            await _moveToNextBlock();
          } else {
            // Se terminaron todos los bloques, volver al primer bloque
            debugPrint('🔁 Todos los bloques terminados - volviendo al primer bloque');
            _currentBlockIndex = 0;
            await _loadCurrentBlock();
          }
        } else {
          // En modo playlist: loop la playlist completa
          if (hasNext) {
            await playNext();
          } else {
            // Volver al inicio de la playlist
            debugPrint('🔁 Playlist terminada - volviendo al inicio');
            _currentTrackIndex = 0;
            _currentTrack = _playlist[0];
            await _player.setUrl(_currentTrack!.streamUrl);
            await _player.play();
            notifyListeners();
          }
        }
        break;

      case 2: // Loop bloque/canción actual
        if (_isBlockMode) {
          // En modo blocks: loop del bloque actual
          if (_currentSongInBlockIndex < _playlist.length - 1) {
            // Hay más canciones en el bloque actual
            await playNext();
          } else {
            // Se terminó el bloque, volver al inicio del bloque
            debugPrint('🔁 Bloque terminado - volviendo al inicio del bloque');
            _currentSongInBlockIndex = 0;
            _currentTrackIndex = 0;
            _currentTrack = _playlist[0];
            await _player.setUrl(_currentTrack!.streamUrl);
            await _player.play();
            notifyListeners();
          }
        } else {
          // En modo playlist: loop de la canción actual
          debugPrint('🔁 Repitiendo canción actual');
          await _player.seek(Duration.zero);
          await _player.play();
        }
        break;

      case 3: // Loop canción sola (solo en modo blocks)
        if (_isBlockMode) {
          debugPrint('🔁 Repitiendo canción actual (modo 3)');
          await _player.seek(Duration.zero);
          await _player.play();
        }
        break;
    }
  }

  // Método auxiliar para cargar el bloque actual
  Future<void> _loadCurrentBlock() async {
    try {
      final currentBlock = _blocks[_currentBlockIndex];
      final songs = currentBlock['songs'] as List<dynamic>;
      final tracks = songs.map((songJson) => _songToJellyfinTrack(songJson)).toList();

      if (tracks.isNotEmpty) {
        _playlist = tracks;
        _currentTrackIndex = 0;
        _currentSongInBlockIndex = 0;
        _currentTrack = tracks[0];

        debugPrint('🔲 Cargando bloque ${currentBlock['name']} con ${tracks.length} canciones');

        notifyListeners();

        await _player.setUrl(_currentTrack!.streamUrl);
        await _player.play();

        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error cargando bloque actual: $e');
    }
  }
}
