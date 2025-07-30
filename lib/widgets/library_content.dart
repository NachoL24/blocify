import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/playlist_summary.dart';
import '../services/playlist_service.dart';

class LibraryContent extends StatefulWidget {
  final List<PlaylistSummary> userPlaylists;
  final bool isLoadingUserPlaylists;
  final void Function(int playlistId, String playlistName)? onPlaylistTap;
  final VoidCallback? onPlaylistsUpdated;

  const LibraryContent({
    super.key,
    required this.userPlaylists,
    required this.isLoadingUserPlaylists,
    this.onPlaylistTap,
    this.onPlaylistsUpdated,
  });

  @override
  State<LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends State<LibraryContent> {
  final PlaylistService _playlistService = PlaylistService.instance;

  void _showCreatePlaylistDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: context.colors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear Nueva Playlist',
                  style: TextStyle(
                    color: context.colors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: context.colors.text),
                  decoration: InputDecoration(
                    labelText: 'Nombre de la playlist',
                    labelStyle: TextStyle(color: context.colors.secondaryText),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: context.colors.lightGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: context.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: TextStyle(color: context.colors.text),
                  decoration: InputDecoration(
                    hintText: 'Descripción (opcional)',
                    hintStyle: TextStyle(color: context.colors.secondaryText),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: context.colors.lightGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: context.primaryColor),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: context.colors.secondaryText),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isNotEmpty) {
                          try {
                            await _playlistService.createPlaylist(
                              name: nameController.text.trim(),
                              description:
                                  descriptionController.text.trim().isEmpty
                                      ? 'Mi nueva playlist'
                                      : descriptionController.text.trim(),
                            );

                            if (mounted) {
                              Navigator.of(context).pop();
                              print(
                                  '🔄 Ejecutando callback onPlaylistsUpdated...');
                              widget.onPlaylistsUpdated?.call();
                            }
                          } catch (e) {
                            if (mounted) {
                              print('❌ Error al crear playlist: $e');
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                      ),
                      child: Text(
                        'Crear',
                        style: TextStyle(color: context.colors.permanentWhite),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu Biblioteca',
            style: TextStyle(
              color: context.colors.text,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _showCreatePlaylistDialog,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: context.colors.lightGray,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colors.secondaryText.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 48,
                    color: context.colors.secondaryText,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Añadir playlist',
                    style: TextStyle(
                      color: context.colors.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
