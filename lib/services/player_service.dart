import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'jellyfin_service.dart';

class PlayerService extends ChangeNotifier {
  static final PlayerService _instance = PlayerService._internal();
  static PlayerService get instance => _instance;

  PlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  // Estado actual del reproductor
  JellyfinTrack? _currentTrack;
  bool _isPlaying = false;
  bool _isPlayerVisible = false;
  List<JellyfinTrack> _playlist = [];
  int _currentTrackIndex = -1;

  // Getters
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

  // Streams
  Stream<bool> get playingStream => _player.playingStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Reproduce una canción de Jellyfin
  Future<void> playJellyfinTrack(JellyfinTrack track,
      {List<JellyfinTrack>? playlist, int? index}) async {
    try {
      _currentTrack = track;
      _isPlayerVisible = true;

      // Si se proporciona una playlist, la configuramos
      if (playlist != null) {
        _playlist = playlist;
        _currentTrackIndex = index ?? playlist.indexOf(track);
      } else {
        _playlist = [track];
        _currentTrackIndex = 0;
      }

      await _player.setUrl(track.streamUrl);
      await _player.play();

      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing track: $e');
    }
  }

  /// Reproduce una nueva canción (método legacy para compatibilidad)
  Future<void> playSong({
    required String audioUrl,
    required String songTitle,
    String? artist,
    String? albumArt,
  }) async {
    // Crear un track temporal para mantener compatibilidad
    final tempTrack = JellyfinTrack(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      name: songTitle,
      artists: artist != null ? [artist] : [],
      artistItems: [],
    );

    await playJellyfinTrack(tempTrack);
  }

  /// Reproduce la siguiente canción en la playlist
  Future<void> playNext() async {
    if (hasNext) {
      _currentTrackIndex++;
      await playJellyfinTrack(_playlist[_currentTrackIndex],
          playlist: _playlist, index: _currentTrackIndex);
    }
  }

  /// Reproduce la canción anterior en la playlist
  Future<void> playPrevious() async {
    if (hasPrevious) {
      _currentTrackIndex--;
      await playJellyfinTrack(_playlist[_currentTrackIndex],
          playlist: _playlist, index: _currentTrackIndex);
    }
  }

  /// Pausa la reproducción
  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
    notifyListeners();
  }

  /// Reanuda la reproducción
  Future<void> play() async {
    await _player.play();
    _isPlaying = true;
    notifyListeners();
  }

  /// Alterna entre play/pause
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Busca a una posición específica
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Detiene la reproducción y limpia el estado
  Future<void> stop() async {
    await _player.stop();
    _currentTrack = null;
    _playlist.clear();
    _currentTrackIndex = -1;
    _isPlaying = false;
    _isPlayerVisible = false;
    notifyListeners();
  }

  /// Oculta el mini reproductor sin detener la música
  void hideMiniPlayer() {
    _isPlayerVisible = false;
    notifyListeners();
  }

  /// Muestra el mini reproductor
  void showMiniPlayer() {
    if (hasSong) {
      _isPlayerVisible = true;
      notifyListeners();
    }
  }

  /// Carga las canciones desde Jellyfin
  Future<List<JellyfinTrack>> loadJellyfinTracks() async {
    try {
      return await JellyfinService.getAllTracks();
    } catch (e) {
      debugPrint('Error loading Jellyfin tracks: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
