import 'package:flutter/material.dart';
import '../models/playlist_summary.dart';
import '../models/artist.dart';
import '../services/playlist_service.dart';
import '../theme/app_colors.dart';

class LibraryContent extends StatelessWidget {
  final List<PlaylistSummary> userPlaylists;
  final List<ArtistSummary>? userArtists;
  final void Function(int playlistId, String playlistName)? onPlaylistTap;
  final VoidCallback? onPlaylistsUpdated;
  final void Function(int playlistId)? onDelete;
  final bool isLoadingUserPlaylists;
  final bool isLoadingUserArtists;
  final VoidCallback? onCreatePlaylist;
  final String selectedFilter;
  final void Function(String filter)? onFilterSelected;
  final String? error;

  const LibraryContent({
    super.key,
    required this.userPlaylists,
    this.userArtists,
    this.onPlaylistTap,
    this.onPlaylistsUpdated,
    required this.onDelete,
    this.isLoadingUserPlaylists = false,
    this.isLoadingUserArtists = false,
    this.onCreatePlaylist,
    required this.selectedFilter,
    this.onFilterSelected,
    this.error,
  });

  Future<void> _deletePlaylist(BuildContext context, int playlistId) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Playlist eliminada correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar playlist: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            error!,
            style: TextStyle(
              color: context.colors.primary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              if (selectedFilter == "playlists" && onCreatePlaylist != null)
                IconButton(
                  icon: Icon(Icons.add, color: context.colors.text),
                  onPressed: onCreatePlaylist,
                  tooltip: 'Crear nueva playlist',
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Filtros
          _buildFilterChips(context),

          const SizedBox(height: 16),

          // Contenido según filtro
          selectedFilter == "playlists"
              ? _buildPlaylistsContent(context)
              : _buildArtistsContent(context),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildFilterChip(context, "playlists", "Playlists"),
        _buildFilterChip(context, "artists", "Artistas"),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String filter, String label) {
    final isSelected = selectedFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onFilterSelected?.call(filter),
      backgroundColor: context.colors.lightGray.withOpacity(0.3),
      selectedColor: context.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : context.colors.text,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildPlaylistsContent(BuildContext context) {
    if (isLoadingUserPlaylists) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userPlaylists.isEmpty) {
      return Center(
        child: Text(
          'Todavía no tenés playlists.',
          style: TextStyle(
            color: context.colors.secondaryText,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userPlaylists.length,
      itemBuilder: (context, index) {
        final playlist = userPlaylists[index];
        return _buildPlaylistTile(context, playlist);
      },
    );
  }

  Widget _buildPlaylistTile(BuildContext context, PlaylistSummary playlist) {
    return Card(
      color: context.colors.lightGray,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildPlaylistCover(context, playlist),
        title: Text(
          playlist.name,
          style: TextStyle(
            color: context.colors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${playlist.songCount} canciones',
          style: TextStyle(
            color: context.colors.secondaryText,
            fontSize: 13,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: context.colors.secondaryText),
          onPressed: () => _deletePlaylist(context, playlist.id),
        ),
        onTap: () => onPlaylistTap?.call(playlist.id, playlist.name),
      ),
    );
  }

  Widget _buildPlaylistCover(BuildContext context, PlaylistSummary playlist) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: context.colors.secondaryText.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          playlist.name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: context.colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildArtistsContent(BuildContext context) {
    if (isLoadingUserArtists) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userArtists == null || userArtists!.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron artistas en tu biblioteca.',
          style: TextStyle(
            color: context.colors.secondaryText,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userArtists!.length,
      itemBuilder: (context, index) {
        final artist = userArtists![index];
        return _buildArtistTile(context, artist);
      },
    );
  }

  Widget _buildArtistTile(BuildContext context, ArtistSummary artist) {
    return Card(
      color: context.colors.lightGray,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildArtistAvatar(context, artist),
        title: Text(
          artist.name,
          style: TextStyle(
            color: context.colors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${artist.songCount} canciones',
          style: TextStyle(
            color: context.colors.secondaryText,
            fontSize: 13,
          ),
        ),
        onTap: () {
          // TODO: Implementar navegación a vista de artista
        },
      ),
    );
  }

  Widget _buildArtistAvatar(BuildContext context, ArtistSummary artist) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: context.colors.secondaryText.withOpacity(0.2),
      child: Text(
        artist.name.substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: context.colors.text,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}