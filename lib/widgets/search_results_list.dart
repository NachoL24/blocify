import 'package:flutter/material.dart';
import '../models/playlist_summary.dart';
import '../models/song.dart';
import '../services/auth0_service.dart';
import '../services/playlist_service.dart';
import '../widgets/song_tile.dart';

class SearchResultsList extends StatelessWidget {
  final List<Song> results;
  final Function(Song) onSongTap;

  const SearchResultsList({
    super.key,
    required this.results,
    required this.onSongTap,
  });

  void _showAddToPlaylistDialog(BuildContext context, Song song) async {
    final userId = Auth0Service.instance.currentUser?.id;
    if (userId == null) return;

    final playlists = await PlaylistService.instance.getUserPlaylists(userId.toString());

    final selected = await showDialog<PlaylistSummary>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Elegí una playlist'),
        children: playlists.map((p) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, p),
            child: Text(p.name),
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      try {
        await PlaylistService.instance.addSongToPlaylist(
          playlistId: selected.id,
          song: song,
        );
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
        return SongTile(
          song: song,
          onTap: () => onSongTap(song),
          onAddToPlaylist: () => _showAddToPlaylistDialog(context, song),
          mode: SongTileMode.search,
        );
      },
    );
  }
}
