import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/song.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final bool showAlbum;
  final Widget? trailing;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.showAlbum = false,
    this.trailing,
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
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: song.picture != null && song.picture!.isNotEmpty
              ? Image.memory(
                  song.picture!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _getRandomColor(),
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 24,
                      ),
                    );
                  },
                )
              : Container(
                  color: _getRandomColor(),
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 24,
                  ),
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
      trailing: trailing ??
          Icon(
            Icons.more_horiz,
            color: context.colors.secondaryText,
          ),
      onTap: onTap,
    );
  }
}
