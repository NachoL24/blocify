import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/playlist_summary.dart';

class DiscoverCard extends StatelessWidget {
  final PlaylistSummary playlist;
  final VoidCallback onTap;

  const DiscoverCard({
    super.key,
    required this.playlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: context.colors.secondaryText,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  playlist.name,
                  style: TextStyle(
                    color: context.colors.text,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                playlist.name,
                style: TextStyle(
                  color: context.colors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
