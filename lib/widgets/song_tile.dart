import 'package:blocify/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../models/song.dart';

enum SongTileMode {
  playlist,
  search,
  block,
}

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final bool showAlbum;
  final Widget? trailing;
  final VoidCallback? onRemove;
  final VoidCallback? onAddToBlock;
  final VoidCallback? onAddToPlaylist;
  final SongTileMode mode;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    required this.mode,
    this.showAlbum = false,
    this.trailing,
    this.onRemove,
    this.onAddToBlock,
    this.onAddToPlaylist,
  });

  Color _getRandomColor() {
    final colors = [
      const Color(0xFFFF7043),
      const Color(0xFF42A5F5),
      const Color(0xFF4CAF50),
      const Color(0xFFFFA726),
      const Color(0xFFAB47BC),
      const Color(0xFF26A69A),
    ];
    return colors[song.itemId.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: song.picture != null && song.picture!.isNotEmpty
                ? Image.network(
                    song.picture!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: _getRandomColor(),
                        child:
                            const Icon(Icons.music_note, color: Colors.white),
                      );
                    },
                  )
                : Container(
                    color: _getRandomColor(),
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
          ),
        ),
        title: Text(
          song.name,
          style: TextStyle(
            color: context.colors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: showAlbum && song.album.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.artist,
                    style: TextStyle(
                      color: context.colors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    song.album,
                    style: TextStyle(
                      color: context.colors.secondaryText.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : Text(
                song.artist,
                style: TextStyle(
                  color: context.colors.secondaryText,
                  fontSize: 14,
                ),
              ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_horiz, color: context.colors.secondaryText),
          onSelected: (value) {
            switch (value) {
              case 'remove':
                onRemove?.call();
                break;
              case 'addToBlock':
                onAddToBlock?.call();
                break;
              case 'addToPlaylist':
                onAddToPlaylist?.call();
                break;
            }
          },
          itemBuilder: (context) {
            switch (mode) {
              case SongTileMode.playlist:
                return [
                  PopupMenuItem(
                    value: 'addToBlock',
                    child: Row(
                      children: [
                        Icon(Icons.add, color: context.colors.text, size: 20),
                        SizedBox(width: 8),
                        Text('Añadir a Bloque',
                            style: TextStyle(color: context.colors.text)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Eliminar de la Playlist',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ];
              case SongTileMode.search:
                return [
                  PopupMenuItem(
                    value: 'addToPlaylist',
                    child: Row(
                      children: [
                        Icon(Icons.add, color: context.colors.text, size: 20),
                        SizedBox(width: 8),
                        Text('Añadir a Playlist',
                            style: TextStyle(color: context.colors.text)),
                      ],
                    ),
                  ),
                ];
              case SongTileMode.block:
                return [
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Eliminar del bloque',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ];
            }
          },
        ),
      ),
    );
  }
}
