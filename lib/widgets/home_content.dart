import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth0_service.dart';
import '../models/playlist_summary.dart';
import '../widgets/welcome_header.dart';
import '../widgets/playlist_section.dart';
import '../screens/playlist_detail_screen.dart';

class HomeContent extends StatelessWidget {
  final Auth0Service auth0Service;
  final List<PlaylistSummary> topPlaylists;
  final List<PlaylistSummary> discoverPlaylists;
  final List<PlaylistSummary> userPlaylists;
  final bool isLoadingTopPlaylists;
  final bool isLoadingDiscoverPlaylists;
  final bool isLoadingUserPlaylists;

  const HomeContent({
    super.key,
    required this.auth0Service,
    required this.topPlaylists,
    required this.discoverPlaylists,
    required this.userPlaylists,
    required this.isLoadingTopPlaylists,
    required this.isLoadingDiscoverPlaylists,
    required this.isLoadingUserPlaylists,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WelcomeHeader(auth0Service: auth0Service),
          const SizedBox(height: 32),
          PlaylistSection(
            title: 'Top Playlists',
            playlists: topPlaylists,
            isLoading: isLoadingTopPlaylists,
            onPlaylistTap: (playlist) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistDetailScreen(
                    playlistId: playlist.id,
                    playlistName: playlist.name,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          PlaylistSection(
            title: 'Discover',
            playlists: discoverPlaylists,
            isLoading: isLoadingDiscoverPlaylists,
            onPlaylistTap: (playlist) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistDetailScreen(
                    playlistId: playlist.id,
                    playlistName: playlist.name,
                  ),
                ),
              );
            },
          ),
          if (userPlaylists.isNotEmpty) ...[
            const SizedBox(height: 32),
            PlaylistSection(
              title: 'Tus Playlists',
              playlists: userPlaylists,
              isLoading: isLoadingUserPlaylists,
              onPlaylistTap: (playlist) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Abriendo ${playlist.name}...'),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
