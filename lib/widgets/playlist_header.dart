import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/playlist.dart';

class PlaylistHeader extends StatelessWidget {
  final Playlist playlist;

  const PlaylistHeader({
    super.key,
    required this.playlist,
  });

  String _getTotalDuration() {
    final songsSeconds =
        playlist.songs.fold(0, (sum, song) => sum + song.duration);
    final blockSeconds = playlist.blocks.fold(
        0,
        (sum, block) =>
            sum +
            block.songs.fold(0, (blockSum, song) => blockSum + song.duration));
    final totalSeconds = songsSeconds + blockSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String getTotalSongs() {
    return (playlist.songs.length +
            playlist.blocks.fold(0, (sum, block) => sum + block.songs.length))
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Imagen de la playlist
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: context.colors.secondaryText,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                playlist.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Información de la playlist
        Text(
          '${getTotalSongs()} songs • ${_getTotalDuration()}',
          style: TextStyle(
            color: context.colors.secondaryText,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
