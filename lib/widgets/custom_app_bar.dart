import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsTap;

  const CustomAppBar({
    super.key,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.colors.background,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            child: Image.asset(
              'assets/images/logo.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
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
          icon: Icon(Icons.settings, color: context.colors.text),
          onPressed: onSettingsTap,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
