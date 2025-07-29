import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/playlist_service.dart';
import '../services/player_service.dart';
import '../models/playlist.dart';
import '../widgets/playlist_content.dart';
import '../widgets/main_layout.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final int playlistId;
  final String playlistName;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final PlaylistService _playlistService = PlaylistService.instance;
  Playlist? _playlist;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylistDetails();
  }

  Future<void> _loadPlaylistDetails() async {
    try {
      final playlist =
          await _playlistService.getPlaylistById(widget.playlistId);
      if (mounted) {
        setState(() {
          _playlist = playlist;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar playlist: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.colors.text),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Playlist',
            style: TextStyle(
              color: context.colors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _playlist == null
                ? Center(
                    child: Text(
                      'No se pudo cargar la playlist',
                      style: TextStyle(color: context.colors.text),
                    ),
                  )
                : PlaylistContent(
                    playlist: _playlist!,
                    onSongTap: (song) async {
                      try {
                        final playerService = PlayerService.instance;
                        final tracks = await playerService.loadJellyfinTracks();

                        final badBunnyTrack = tracks.firstWhere(
                          (track) =>
                              track.id == '5e8be675d5e30a4c8eb05bc4f43abafe',
                          orElse: () => tracks.isNotEmpty
                              ? tracks.first
                              : throw Exception('No tracks available'),
                        );

                        await playerService.playJellyfinTrack(badBunnyTrack,
                            playlist: tracks);

                        // Mostrar mini player y NO navegar automáticamente
                        playerService.showMiniPlayer();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Reproduciendo ${badBunnyTrack.name}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al reproducir: $e')),
                          );
                        }
                      }
                    },
                  ),
      ),
    );
  }
}
