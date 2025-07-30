import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../widgets/playlist_header.dart';
import '../widgets/blocks_section.dart';
import '../widgets/songs_section.dart';

class PlaylistContent extends StatelessWidget {
  final Playlist playlist;
  final Function(Song) onSongTap;

  const PlaylistContent({
    super.key,
    required this.playlist,
    required this.onSongTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlaylistHeader(playlist: playlist),
          const SizedBox(height: 32),
          BlocksSection(blocks: playlist.blocks),
          const SizedBox(height: 24),
          SongsSection(
            songs: playlist.songs,
            onSongTap: onSongTap,
          ),
        ],
      ),
    );
  }
}
