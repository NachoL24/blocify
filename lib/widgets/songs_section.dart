import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/song.dart';
import '../widgets/song_tile.dart';

class SongsSection extends StatelessWidget {
  final List<Song> songs;
  final Function(Song) onSongTap;
  final Function(Song) onRemove;
  final Function(Song) onAddToBlock;
  final SongTileMode mode;

  const SongsSection({
    super.key,
    required this.songs,
    required this.onSongTap,
    required this.onRemove,
    required this.onAddToBlock,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Songs',
          style: TextStyle(
            color: context.colors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return SongTile(
              song: song,
              onTap: () => onSongTap(song),
              onRemove: () => onRemove(song),
              onAddToBlock: () => onAddToBlock(song),
              mode: mode,
            );
          },
        ),
      ],
    );
  }
}
