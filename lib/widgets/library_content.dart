import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LibraryContent extends StatelessWidget {
  const LibraryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_music,
            size: 64,
            color: context.colors.secondaryText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Biblioteca',
            style: TextStyle(
              color: context.colors.text,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente...',
            style: TextStyle(
              color: context.colors.secondaryText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
