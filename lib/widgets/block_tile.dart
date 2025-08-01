import 'package:blocify/widgets/song_tile.dart';
import 'package:flutter/material.dart';
import '../models/block.dart';
import '../services/jellyfin_service.dart';
import '../services/player_service.dart';
import '../theme/app_colors.dart';
import '../screens/edit_block_screen.dart';
import '../services/playlist_service.dart';

class BlockTile extends StatefulWidget {
  final Block block;
  final int playlistId;
  final bool isOwner;
  final VoidCallback onRefresh;

  const BlockTile({
    super.key,
    required this.block,
    required this.playlistId,
    required this.isOwner,
    required this.onRefresh,
  });

  @override
  State<BlockTile> createState() => _BlockTileState();
}

class _BlockTileState extends State<BlockTile> {
  bool _isExpanded = false;
  bool _isDeleting = false;

  Color _getBlockColor() {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFFFFA726),
      const Color(0xFF42A5F5),
      const Color(0xFFAB47BC),
      const Color(0xFF26A69A),
      const Color(0xFFFF7043),
    ];
    return colors[widget.block.id % colors.length];
  }

  Future<void> _editBlock() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditBlockScreen(
          blockId: widget.block.id,
          initialName: widget.block.name,
          initialDescription: widget.block.description,
        ),
      ),
    );

    if (result == true && mounted) {
      widget.onRefresh();
    }
  }

  Future<void> _deleteBlock() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Sublist'),
        content: const Text('¿Estás seguro de que quieres eliminar este sublist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeleting = true);
      try {
        await PlaylistService.instance.deleteBlock(
          playlistId: widget.playlistId,
          blockId: widget.block.id,
        );
        if (mounted) widget.onRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bloque eliminado con éxito'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          ListTile(
            onTap: () async {
              if (widget.block.songs.isNotEmpty) {
                final firstSong = widget.block.songs.first;
                final player = PlayerService.instance;
                player.setBlockMode(true);
                await player.playFromBlock(
                  widget.playlistId,
                  widget.block.id,
                  firstSong.id,
                );
              }
            },
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getBlockColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.queue_music, color: Colors.white),
            ),
            title: Text(
              widget.block.name,
              style: TextStyle(
                color: context.colors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '${widget.block.songs.length} songs',
              style: TextStyle(color: context.colors.secondaryText),
            ),
            trailing: SizedBox(
              width: 96,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: context.colors.text,
                    ),
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  ),
                  if (widget.isOwner)
                    PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'edit') await _editBlock();
                        if (value == 'delete') await _deleteBlock();
                      },
                    ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.block.description?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        widget.block.description!,
                        style: TextStyle(color: context.colors.secondaryText),
                      ),
                    ),
                  const Divider(),
                  ...widget.block.songs.map((song) => SongTile(
                    song: song,
                    onTap: () async {
                      final player = PlayerService.instance;
                      player.setBlockMode(true);
                      await player.playSong(
                        audioUrl: JellyfinService.getStreamUrl(song.itemId),
                        songTitle: song.name,
                        artist: song.artist,
                        albumArt: song.picture,
                      );
                    },
                  )),
                ],
              ),
            ),
        ],
      ),
    );
  }

}