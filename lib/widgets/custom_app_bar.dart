import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onProfileTap;

  const CustomAppBar({
    super.key,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.colors.background,
      elevation: 0,
      title: Row(
        children: [
          Icon(
            Icons.music_note_rounded,
            color: context.primaryColor,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            'Blocify',
            style: TextStyle(
              color: context.colors.text,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.person, color: context.colors.text),
          onPressed: onProfileTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
