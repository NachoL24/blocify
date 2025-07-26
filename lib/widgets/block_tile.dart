import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/block.dart';
import '../widgets/song_tile.dart';

class BlockTile extends StatefulWidget {
  final Block block;
  final VoidCallback onTap;

  const BlockTile({
    super.key,
    required this.block,
    required this.onTap,
  });

  @override
  State<BlockTile> createState() => _BlockTileState();
}

class _BlockTileState extends State<BlockTile> {
  bool _isExpanded = false;

  Color _getBlockColor() {
    // Generar color basado en el ID del block
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getBlockColor(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.queue_music,
              color: Colors.white,
              size: 24,
            ),
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
            style: TextStyle(
              color: context.colors.secondaryText,
              fontSize: 14,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: context.colors.text,
            ),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Reproduciendo ${widget.block.name}')),
            );
          },
        ),
        if (_isExpanded)
          // Lista de canciones del bloque
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.block.songs.length,
            itemBuilder: (context, index) {
              final song = widget.block.songs[index];
              return Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SongTile(
                  song: song,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reproduciendo ${song.name} desde ${widget.block.name}...')),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
