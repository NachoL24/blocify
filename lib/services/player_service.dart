import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'jellyfin_service.dart';

class PlayerService extends ChangeNotifier {
  static final PlayerService _instance = PlayerService._internal();
  static PlayerService get instance => _instance;

  PlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  JellyfinTrack? _currentTrack;
  bool _isPlaying = false;
  bool _isPlayerVisible = false;
  List<JellyfinTrack> _playlist = [];
  int _currentTrackIndex = -1;

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
        _playlist = playlist;
        _currentTrackIndex = index ?? playlist.indexOf(track);
      } else {
        _playlist = [track];
        _currentTrackIndex = 0;
      }

      // Notificar inmediatamente que tenemos una canción cargada
      notifyListeners();

      await _player.setUrl(track.streamUrl);
      await _player.play();

      _isPlaying = true;
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
    if (hasNext) {
      _currentTrackIndex++;
      await playJellyfinTrack(_playlist[_currentTrackIndex],
          playlist: _playlist, index: _currentTrackIndex);
    }
  }

  Future<void> playPrevious() async {
    if (hasPrevious) {
      _currentTrackIndex--;
      await playJellyfinTrack(_playlist[_currentTrackIndex],
          playlist: _playlist, index: _currentTrackIndex);
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> play() async {
    await _player.play();
    _isPlaying = true;
    notifyListeners();
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
    _isPlaying = false;
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

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
