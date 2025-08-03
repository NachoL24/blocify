import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/playlist_summary.dart';
import '../models/artist.dart';
import '../services/playlist_service.dart';
import '../theme/app_colors.dart';
import '../screens/edit_playlist_screen.dart';

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Playlist eliminada correctamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar playlist: $e')),
          );
        }
      }
    }
  }

  void _navigateToEditPlaylist(BuildContext context, PlaylistSummary playlist) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPlaylistScreen(playlist: playlist),
      ),
    );

    if (updated == true && onPlaylistsUpdated != null && mounted) {
      onPlaylistsUpdated!();
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

  Widget _buildPlaylistTile(BuildContext context, PlaylistSummary playlistSummary) {
    return FutureBuilder<Playlist>(
      future: PlaylistService.instance.getPlaylistById(playlistSummary.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Cargando...'),
          );
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return ListTile(
            title: Text(playlistSummary.name),
            subtitle: const Text('Error al cargar canciones'),
            leading: _buildPlaylistCover(context, playlistSummary),
            trailing: const Icon(Icons.error, color: Colors.red),
          );
        }

        final playlist = snapshot.data!;
        final allSongs = [...playlist.songs, ...playlist.blocks.expand((b) => b.songs)];
        final uniqueSongs = {for (var s in allSongs) s.id: s}.values.toList();

        return Card(
          color: context.colors.lightGray,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: _buildPlaylistCover(context, playlistSummary),
            title: Text(
              playlistSummary.name,
              style: TextStyle(
                color: context.colors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${uniqueSongs.length} songs',
              style: TextStyle(
                color: context.colors.secondaryText,
                fontSize: 13,
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: context.colors.secondaryText),
              onSelected: (value) async {
                if (value == 'edit') {
                  final edited = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPlaylistScreen(playlist: playlistSummary),
                    ),
                  );

                  if (edited == true && onPlaylistsUpdated != null) {
                    onPlaylistsUpdated!();
                  }
                } else if (value == 'delete') {
                  _deletePlaylist(context, playlistSummary.id);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => onPlaylistTap?.call(playlistSummary.id, playlistSummary.name),
          ),
        );
      },
    );
  }


  Widget _buildPlaylistCover(BuildContext context, PlaylistSummary playlist) {
    final colors = [
      Colors.teal,
      Colors.deepOrange,
      Colors.indigo,
      Colors.green,
      Colors.purple,
      Colors.pink,
    ];
    final color = colors[playlist.id % colors.length];

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(Icons.music_video, color: Colors.white),
      ),
    );
  }


  Widget _buildArtistsContent(BuildContext context) {
    final validArtists = userArtists?.where((a) => a.songCount > 0).toSet().toList() ?? [];

    if (isLoadingUserArtists) {
      return const Center(child: CircularProgressIndicator());
    }

    if (validArtists.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron artistas con canciones.',
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
      itemCount: validArtists.length,
      itemBuilder: (context, index) {
        final artist = validArtists[index];
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
          '${artist.songCount} songs',
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
    final colors = [
      Colors.redAccent,
      Colors.deepPurple,
      Colors.teal,
      Colors.orangeAccent,
      Colors.indigo,
      Colors.green,
      Colors.blueGrey,
    ];
    final bgColor = colors[artist.id.hashCode % colors.length].withOpacity(0.6);
    final initial = artist.name.isNotEmpty ? artist.name[0].toUpperCase() : '?';

    return artist.imageUrl != null
        ? CircleAvatar(
      radius: 24,
      backgroundImage: NetworkImage(artist.imageUrl!),
    )
        : CircleAvatar(
      radius: 24,
      backgroundColor: bgColor,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  bool get mounted => true;
}