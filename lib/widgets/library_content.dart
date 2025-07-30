// widgets/library_content.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/playlist_summary.dart';
import '../services/playlist_service.dart';

class LibraryContent extends StatelessWidget {
  final List<PlaylistSummary> userPlaylists;
  final void Function(int playlistId, String playlistName)? onPlaylistTap;
  final VoidCallback? onPlaylistsUpdated;
  final void Function(int playlistId)? onDelete;
  final bool isLoadingUserPlaylists;
  final VoidCallback? onCreatePlaylist; // Nuevo parámetro
  final String selectedFilter;
  final void Function(String filter)? onFilterSelected;

  const LibraryContent({
    super.key,
    required this.userPlaylists,
    this.onPlaylistTap,
    this.onPlaylistsUpdated,
    this.onDelete,
    this.isLoadingUserPlaylists = false,
    this.onCreatePlaylist, // Añadido aquí
    this.onFilterSelected,
    required this.selectedFilter,
  });

  void _deletePlaylist(BuildContext context, int playlistId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar Playlist"),
        content: const Text("¿Estás seguro de que querés eliminar esta playlist?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Eliminar"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await PlaylistService.instance.deletePlaylist(playlistId);
        onPlaylistsUpdated?.call();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar playlist: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// FILA: Título a la IZQUIERDA y Botón + a la DERECHA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tu Biblioteca',
                style: TextStyle(
                  color: context.colors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: context.colors.text),
                onPressed: onCreatePlaylist,
                tooltip: 'Crear nueva playlist',
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// FILTROS: Playlists | Artists
          Row(
            children: [
              TextButton(
                onPressed: () => onFilterSelected?.call("playlists"),
                child: Text(
                  'Playlists',
                  style: TextStyle(
                    color: selectedFilter == "playlists"
                        ? context.primaryColor
                        : context.colors.text,
                    fontWeight: selectedFilter == "playlists"
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => onFilterSelected?.call("artists"),
                child: Text(
                  'Artists',
                  style: TextStyle(
                    color: selectedFilter == "artists"
                        ? context.primaryColor
                        : context.colors.text,
                    fontWeight: selectedFilter == "artists"
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// LISTADO DE PLAYLISTS
          if (userPlaylists.isEmpty)
            Text(
              'Todavía no tenés playlists.',
              style: TextStyle(
                color: context.colors.secondaryText,
                fontSize: 16,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userPlaylists.length,
              itemBuilder: (context, index) {
                final playlist = userPlaylists[index];
                return GestureDetector(
                  onTap: () => onPlaylistTap?.call(playlist.id, playlist.name),
                  child: Card(
                    color: context.colors.lightGray,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: context.colors.secondaryText.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            playlist.name,
                            style: TextStyle(
                              color: context.colors.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      title: Text(
                        playlist.name,
                        style: TextStyle(
                          color: context.colors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${playlist.songCount} songs',
                        style: TextStyle(
                          color: context.colors.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: context.colors.secondaryText),
                        onPressed: () => _deletePlaylist(context, playlist.id),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}