import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../services/player_service.dart';
import '../theme/app_colors.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});
  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final PlayerService _playerService = PlayerService.instance;

  @override
  void initState() {
    super.initState();
    // Si no hay canción cargada, cargar una desde Jellyfin
    if (!_playerService.hasSong) {
      _loadJellyfinSong();
    }
  }

  Future<void> _loadJellyfinSong() async {
    try {
      final tracks = await _playerService.loadJellyfinTracks();
      if (tracks.isNotEmpty) {
        await _playerService.playJellyfinTrack(tracks.first, playlist: tracks);
      }
    } catch (e) {
      debugPrint('Error loading Jellyfin song: $e');
      // Fallback a una canción de prueba
      _loadDefaultSong();
    }
  }

  void _loadDefaultSong() {
    const audioUrl =
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    const songImageUrl =
        'https://via.placeholder.com/240x240/8A13B2/FFFFFF?text=Blocify';

    _playerService.playSong(
      audioUrl: audioUrl,
      songTitle: 'SoundHelix Song 1',
      artist: 'SoundHelix',
      albumArt: songImageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reproductor',
          style: TextStyle(
            color: context.colors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: context.colors.text,
              size: 24,
            ),
            onPressed: () {
              // TODO: Implementar más opciones
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _playerService,
        builder: (context, child) {
          if (!_playerService.hasSong) {
            return Center(
              child: Text(
                'No hay canción seleccionada',
                style: TextStyle(
                  color: context.colors.text,
                  fontSize: 16,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top section with album art and song info
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Album Art
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 8),
                              blurRadius: 24,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _playerService.currentAlbumArt != null
                              ? Image.network(
                                  _playerService.currentAlbumArt!,
                                  width: 280,
                                  height: 280,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 280,
                                    height: 280,
                                    decoration: BoxDecoration(
                                      color: context.colors.lightGray,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.music_note,
                                      size: 80,
                                      color:
                                          context.colors.text.withOpacity(0.4),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    color: context.colors.lightGray,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: context.colors.text.withOpacity(0.4),
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Song Info
                      Column(
                        children: [
                          Text(
                            _playerService.currentSongTitle ?? '',
                            style: TextStyle(
                              color: context.colors.text,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          if (_playerService.currentArtist != null)
                            Text(
                              _playerService.currentArtist!,
                              style: TextStyle(
                                color: context.colors.text.withOpacity(0.7),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Bottom section with progress and controls
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: StreamBuilder<Duration>(
                          stream: _playerService.positionStream,
                          builder: (_, posSnap) => StreamBuilder<Duration?>(
                            stream: _playerService.durationStream,
                            builder: (_, durSnap) {
                              final position = posSnap.data ?? Duration.zero;
                              final duration = durSnap.data ?? Duration.zero;

                              return ProgressBar(
                                progress: position,
                                total: duration,
                                onSeek: _playerService.seek,
                                progressBarColor: context.colors.primary,
                                thumbColor: context.colors.primary,
                                baseBarColor:
                                    context.colors.text.withOpacity(0.3),
                                barHeight: 4.0,
                                thumbRadius: 6.0,
                                timeLabelTextStyle: TextStyle(
                                  color: context.colors.text.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Controls
                      StreamBuilder<bool>(
                        stream: _playerService.playingStream,
                        initialData: false,
                        builder: (_, snap) {
                          final playing = snap.data!;
                          return Column(
                            children: [
                              // Main controls row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Shuffle button
                                  IconButton(
                                    iconSize: 28,
                                    icon: Icon(
                                      Icons.shuffle,
                                      color:
                                          context.colors.text.withOpacity(0.7),
                                    ),
                                    onPressed: () {
                                      // TODO: Implementar shuffle
                                    },
                                  ),

                                  // Previous button
                                  IconButton(
                                    iconSize: 36,
                                    icon: Icon(
                                      Icons.skip_previous,
                                      color: _playerService.hasPrevious
                                          ? context.colors.text
                                          : context.colors.text
                                              .withOpacity(0.3),
                                    ),
                                    onPressed: _playerService.hasPrevious
                                        ? _playerService.playPrevious
                                        : null,
                                  ),

                                  // Play/Pause button
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: context.colors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      iconSize: 32,
                                      icon: Icon(
                                        playing
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                      onPressed: _playerService.togglePlayPause,
                                    ),
                                  ),

                                  // Next button
                                  IconButton(
                                    iconSize: 36,
                                    icon: Icon(
                                      Icons.skip_next,
                                      color: _playerService.hasNext
                                          ? context.colors.text
                                          : context.colors.text
                                              .withOpacity(0.3),
                                    ),
                                    onPressed: _playerService.hasNext
                                        ? _playerService.playNext
                                        : null,
                                  ),

                                  // Repeat button
                                  IconButton(
                                    iconSize: 28,
                                    icon: Icon(
                                      Icons.repeat,
                                      color:
                                          context.colors.text.withOpacity(0.7),
                                    ),
                                    onPressed: () {
                                      // TODO: Implementar repeat
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
