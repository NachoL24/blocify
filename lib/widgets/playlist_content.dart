import 'package:blocify/widgets/song_tile.dart';
import 'package:flutter/material.dart';
import '../models/block.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../widgets/playlist_header.dart';
import '../widgets/playlist_controls_bar.dart';
import '../widgets/blocks_section.dart';
import '../widgets/songs_section.dart';

class PlaylistContent extends StatelessWidget {
  final Playlist playlist;
  final Function(Song) onSongTap;
  final bool isOwner;
  final VoidCallback onCreateBlock;
  final VoidCallback onRefresh;
  final Function(Song) onRemoveSong;
  final Function(Song) onAddSongToBlock;
  final Function(Block)? onBlockTap;

  const PlaylistContent({
    super.key,
    required this.playlist,
    required this.onSongTap,
    required this.isOwner,
    required this.onCreateBlock,
    required this.onRefresh,
    required this.onRemoveSong,
    required this.onAddSongToBlock,
    this.onBlockTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlaylistHeader(playlist: playlist),
          const SizedBox(height: 24),
          // Barra de controles (Play, Shuffle, etc.)
          PlaylistControlsBar(playlistId: playlist.id),
          const SizedBox(height: 24),
          // Sección de Bloques (con todos los parámetros requeridos)
          BlocksSection(
            blocks: playlist.blocks,
            playlistId: playlist.id,
            isOwner: isOwner,
            onCreateBlock: onCreateBlock,
            onRefresh: onRefresh,
            onBlockTap: onBlockTap,
          ),
          const SizedBox(height: 24),
          // Sección de Canciones
          SongsSection(
            songs: playlist.songs,
            onSongTap: onSongTap,
            onRemove: onRemoveSong,
            onAddToBlock: onAddSongToBlock,
            mode: SongTileMode.playlist,
          ),
        ],
      ),
    );
  }
}