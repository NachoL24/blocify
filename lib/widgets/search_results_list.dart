import 'package:flutter/material.dart';
import '../models/song.dart';
import '../widgets/song_tile.dart';

class SearchResultsList extends StatelessWidget {
  final List<Song> results;
  final Function(Song) onSongTap;

  const SearchResultsList({
    super.key,
    required this.results,
    required this.onSongTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
        return SongTile(
          song: song,
          showAlbum: true,
          onTap: () => onSongTap(song),
        );
      },
    );
  }
}
