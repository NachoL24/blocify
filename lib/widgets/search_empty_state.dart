import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: context.colors.secondaryText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Busca tus canciones favoritas',
            style: TextStyle(
              color: context.colors.secondaryText,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escribe el nombre de una canción para comenzar',
            style: TextStyle(
              color: context.colors.secondaryText.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
