import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/playlist_service.dart';
import '../models/playlist.dart';
import '../models/song.dart';

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
      final playlist = await _playlistService.getPlaylistById(widget.playlistId);
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

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  String _getTotalDuration() {
    if (_playlist == null) return '';
    final totalSeconds = _playlist!.songs.fold(0, (sum, song) => sum + song.duration);
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Playlist cover and info
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: context.colors.card1,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.colors.lightGray.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _playlist!.name,
                                  style: TextStyle(
                                    color: context.colors.text,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _playlist!.name,
                              style: TextStyle(
                                color: context.colors.text,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_playlist!.songs.length} songs • ${_getTotalDuration()}',
                              style: TextStyle(
                                color: context.colors.secondaryText,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Sublists section
                      Text(
                        'Sublists',
                        style: TextStyle(
                          color: context.colors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Mock sublists
                      _SublistTile(
                        title: 'Sublist 1',
                        subtitle: '10 songs',
                        color: const Color(0xFF4CAF50),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Abriendo Sublist 1...')),
                          );
                        },
                      ),
                      _SublistTile(
                        title: 'Sublist 2',
                        subtitle: '10 songs',
                        color: const Color(0xFFFFA726),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Abriendo Sublist 2...')),
                          );
                        },
                      ),
                      _SublistTile(
                        title: 'Sublist 3',
                        subtitle: '10 songs',
                        color: const Color(0xFF42A5F5),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Abriendo Sublist 3...')),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Songs section
                      Text(
                        'Songs',
                        style: TextStyle(
                          color: context.colors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Songs list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _playlist!.songs.length,
                        itemBuilder: (context, index) {
                          final song = _playlist!.songs[index];
                          return _SongTile(
                            song: song,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Reproduciendo ${song.name}...')),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _SublistTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SublistTile({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.queue_music,
          color: Colors.white,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: context.colors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: context.colors.secondaryText,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.more_horiz,
        color: context.colors.secondaryText,
      ),
      onTap: onTap,
    );
  }
}

class _SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _SongTile({
    required this.song,
    required this.onTap,
  });

  Color _getRandomColor() {
    final colors = [
      const Color(0xFFFF7043),
      const Color(0xFF42A5F5),
      const Color(0xFF4CAF50),
      const Color(0xFFFFA726),
      const Color(0xFFAB47BC),
      const Color(0xFF26A69A),
    ];
    return colors[song.id % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: song.picture != null && song.picture!.isNotEmpty
              ? Image.memory(
                  song.picture!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _getRandomColor(),
                      child: Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 24,
                      ),
                    );
                  },
                )
              : Container(
                  color: _getRandomColor(),
                  child: Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
        ),
      ),
      title: Text(
        song.name,
        style: TextStyle(
          color: context.colors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        song.artist,
        style: TextStyle(
          color: context.colors.secondaryText,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.more_horiz,
        color: context.colors.secondaryText,
      ),
      onTap: onTap,
    );
  }
}
