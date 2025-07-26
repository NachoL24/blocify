import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../widgets/mini_player.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final bool showMiniPlayer;

  const MainLayout({
    super.key,
    required this.child,
    this.showMiniPlayer = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          child,
          if (showMiniPlayer)
            Positioned(
              left: 0,
              right: 0,
              bottom:
                  80, 
              child: AnimatedBuilder(
                animation: PlayerService.instance,
                builder: (context, _) {
                  final playerService = PlayerService.instance;

                  if (!playerService.isPlayerVisible ||
                      !playerService.hasSong) {
                    return const SizedBox.shrink();
                  }

                  return MiniPlayer(
                    songTitle: playerService.currentSongTitle,
                    artistName: playerService.currentArtist,
                    albumArt: playerService.currentAlbumArt,
                    isPlaying: playerService.isPlaying,
                    onPlayPause: playerService.togglePlayPause,
                    onTap: () {
                      Navigator.pushNamed(context, '/player');
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
