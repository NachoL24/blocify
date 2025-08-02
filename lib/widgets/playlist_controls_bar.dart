import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../theme/app_colors.dart';

class PlaylistControlsBar extends StatelessWidget {
  final int playlistId;
  final VoidCallback? onPlayPressed;

  const PlaylistControlsBar({
    super.key,
    required this.playlistId,
    this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PlayerService.instance,
      builder: (context, child) {
        final playerService = PlayerService.instance;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón de reproducir
              Container(
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 28,
                  icon: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    try {
                      await playerService.playEntirePlaylist(playlistId);
                      onPlayPressed?.call();
                    } catch (e) {
                      debugPrint('Error reproduciendo playlist: $e');
                    }
                  },
                  tooltip: 'Reproducir playlist',
                ),
              ),

              // Botón de shuffle/aleatorio
              Container(
                decoration: BoxDecoration(
                  color: playerService.isRandomMode
                      ? context.colors.primary
                      : context.colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colors.primary,
                    width: 2,
                  ),
                ),
                child: IconButton(
                  iconSize: 24,
                  icon: Icon(
                    Icons.shuffle,
                    color: playerService.isRandomMode
                        ? Colors.white
                        : context.colors.primary,
                  ),
                  onPressed: () {
                    playerService.setRandomMode(!playerService.isRandomMode);
                  },
                  tooltip: playerService.isRandomMode
                      ? 'Desactivar aleatorio'
                      : 'Activar aleatorio',
                ),
              ),

              // Botón de bloques
              Container(
                decoration: BoxDecoration(
                  color: playerService.isBlockMode
                      ? context.colors.primary
                      : context.colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colors.primary,
                    width: 2,
                  ),
                ),
                child: IconButton(
                  iconSize: 24,
                  icon: Icon(
                    Icons.view_module,
                    color: playerService.isBlockMode
                        ? Colors.white
                        : context.colors.primary,
                  ),
                  onPressed: () {
                    playerService.setBlockMode(!playerService.isBlockMode);
                  },
                  tooltip: playerService.isBlockMode
                      ? 'Desactivar bloques'
                      : 'Activar bloques',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
