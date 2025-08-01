import 'package:flutter/material.dart';
import '../models/block.dart';
import '../theme/app_colors.dart';
import 'block_tile.dart';

class BlocksSection extends StatelessWidget {
  final List<Block> blocks;
  final int playlistId;
  final bool isOwner;
  final VoidCallback onCreateBlock;
  final VoidCallback onRefresh;

  const BlocksSection({
    super.key,
    required this.blocks,
    required this.playlistId,
    required this.isOwner,
    required this.onCreateBlock,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bloques',
              style: TextStyle(
                color: context.colors.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isOwner)
              IconButton(
                icon: Icon(Icons.add, color: context.primaryColor),
                onPressed: onCreateBlock,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (blocks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No hay bloques en esta playlist',
              style: TextStyle(color: context.colors.secondaryText),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: blocks.length,
            itemBuilder: (context, index) => BlockTile(
              block: blocks[index],
              playlistId: playlistId,
              isOwner: isOwner,
              onRefresh: onRefresh,
            ),
          ),
      ],
    );
  }
}