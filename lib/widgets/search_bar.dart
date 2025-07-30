import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final VoidCallback onClear;

  const SearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.lightGray.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: context.colors.text),
        decoration: InputDecoration(
          hintText: 'Buscar canciones...',
          hintStyle: TextStyle(color: context.colors.secondaryText),
          prefixIcon: Icon(
            Icons.search,
            color: context.colors.secondaryText,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: context.colors.secondaryText,
                  ),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
