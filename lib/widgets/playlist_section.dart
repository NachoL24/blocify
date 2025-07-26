import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/playlist_summary.dart';
import '../widgets/discover_card.dart';

class PlaylistSection extends StatelessWidget {
  final String title;
  final List<PlaylistSummary> playlists;
  final bool isLoading;
  final Function(PlaylistSummary) onPlaylistTap;

  const PlaylistSection({
    super.key,
    required this.title,
    required this.playlists,
    required this.isLoading,
    required this.onPlaylistTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.colors.text,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return DiscoverCard(
                      playlist: playlist,
                      onTap: () => onPlaylistTap(playlist),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
