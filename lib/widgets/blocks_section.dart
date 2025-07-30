import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/block.dart';
import '../widgets/block_tile.dart';

class BlocksSection extends StatelessWidget {
  final List<Block> blocks;

  const BlocksSection({
    super.key,
    required this.blocks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sublists',
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
          itemCount: blocks.length,
          itemBuilder: (context, index) {
            final block = blocks[index];
            return BlockTile(
              block: block,
              onTap: () {},
            );
          },
        ),
      ],
    );
  }
}
