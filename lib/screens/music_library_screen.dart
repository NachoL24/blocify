import 'package:flutter/material.dart';
import '../services/jellyfin_service.dart';
import '../services/player_service.dart';
import '../theme/app_colors.dart';

class MusicLibraryScreen extends StatefulWidget {
  const MusicLibraryScreen({super.key});

  @override
  State<MusicLibraryScreen> createState() => _MusicLibraryScreenState();
}

class _MusicLibraryScreenState extends State<MusicLibraryScreen> {
  List<JellyfinTrack>? _tracks;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final tracks = await JellyfinService.getAllTracks();

      setState(() {
        _tracks = tracks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar las canciones: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(
          'Biblioteca Musical',
          style: TextStyle(
            color: context.colors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: context.colors.text),
            onPressed: _loadTracks,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: context.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Cargando canciones...',
              style: TextStyle(color: context.colors.text),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.colors.text.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: context.colors.text),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTracks,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_tracks == null || _tracks!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off,
              size: 64,
              color: context.colors.text.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron canciones',
              style: TextStyle(color: context.colors.text),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tracks!.length,
      itemBuilder: (context, index) {
        final track = _tracks![index];
        return _TrackTile(
          track: track,
          onTap: () => _playTrack(track, index),
        );
      },
    );
  }

  Future<void> _playTrack(JellyfinTrack track, int index) async {
    try {
      await PlayerService.instance.playJellyfinTrack(
        track,
        playlist: _tracks!,
        index: index,
      );

      // Mostrar mini reproductor
      PlayerService.instance.showMiniPlayer();

      // Opcional: navegar al reproductor completo
      if (mounted) {
        Navigator.pushNamed(context, '/player');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reproducir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _TrackTile extends StatelessWidget {
  final JellyfinTrack track;
  final VoidCallback onTap;

  const _TrackTile({
    required this.track,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colors.card1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: track.imageUrl != null
              ? Image.network(
                  track.imageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildDefaultIcon(context),
                )
              : _buildDefaultIcon(context),
        ),
        title: Text(
          track.name,
          style: TextStyle(
            color: context.colors.text,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          track.primaryArtist,
          style: TextStyle(
            color: context.colors.text.withOpacity(0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.play_arrow,
          color: context.primaryColor,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDefaultIcon(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      color: context.colors.lightGray,
      child: Icon(
        Icons.music_note,
        color: context.colors.text.withOpacity(0.5),
      ),
    );
  }
}
