import 'package:flutter/foundation.dart';
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
  }

  final AudioPlayer _player = AudioPlayer();

  JellyfinTrack? _currentTrack;
  bool _isPlaying = false;
  bool _isPlayerVisible = false;
  List<JellyfinTrack> _playlist = [];
  int _currentTrackIndex = -1;
  bool _isRandomMode = false;
  int? _currentPlaylistId;
  List<JellyfinTrack> _originalQueue = [];

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
  int? get currentPlaylistId => _currentPlaylistId;

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
    logPlaylistState();

    if (hasNext) {
      _currentTrackIndex++;
      final nextTrack = _playlist[_currentTrackIndex];
      _currentTrack = nextTrack;
      _isPlayerVisible = true;

      debugPrint('🎵 Moving to next track: ${nextTrack.name}');

      // Si estamos reproduciendo desde una playlist del backend,
      // actualizar la cola para eliminar la canción actual
      if (_currentPlaylistId != null) {
        _removeCurrentSongFromQueue();
      }

      notifyListeners(); // Notificar antes de la operación asíncrona

      try {
        await _player.setUrl(nextTrack.streamUrl);
        await _player.play();
        notifyListeners(); // Notificar después también
        logPlaylistState();
      } catch (e) {
        debugPrint('Error playing next track: $e');
      }
    } else {
      debugPrint('🎵 No next track available');
    }
  }

  Future<void> playPrevious() async {
    debugPrint('🎵 playPrevious() called');
    logPlaylistState();

    if (hasPrevious) {
      _currentTrackIndex--;
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
        block: false, // Como solicitas, block debe ser false
      );

      // Convertir las canciones del backend a JellyfinTrack
      final songs = queueData['songs'] as List<dynamic>;
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

      // Eliminar la canción actual de la cola para evitar duplicados
      _removeCurrentSongFromQueue();

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
    notifyListeners();
  }

  void setPlaylistId(int playlistId) {
    _currentPlaylistId = playlistId;
    notifyListeners();
  }

  void addToQueue(List<JellyfinTrack> tracks) {
    _originalQueue.addAll(tracks);
    notifyListeners();
  }

  void clearQueue() {
    _originalQueue.clear();
    notifyListeners();
  }

  List<JellyfinTrack> getQueue() {
    return List.unmodifiable(_originalQueue);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
