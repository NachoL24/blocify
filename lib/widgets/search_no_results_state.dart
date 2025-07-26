import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SearchNoResultsState extends StatelessWidget {
  const SearchNoResultsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_off,
            size: 64,
            color: context.colors.secondaryText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: TextStyle(
              color: context.colors.secondaryText,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otro término de búsqueda',
            style: TextStyle(
              color: context.colors.secondaryText.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
