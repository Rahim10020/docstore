import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SearchSuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const SearchSuggestionChip({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(text, style: TextStyle(color: AppTheme.textPrimary)),
      ),
    );
  }
}

