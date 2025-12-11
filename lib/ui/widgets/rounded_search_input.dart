import 'package:flutter/material.dart';
import '../../core/theme.dart';

class RoundedSearchInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const RoundedSearchInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  @override
  State<RoundedSearchInput> createState() => _RoundedSearchInputState();
}

class _RoundedSearchInputState extends State<RoundedSearchInput> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  @override
  void didUpdateWidget(covariant RoundedSearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleChange);
      widget.controller.addListener(_handleChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: AppTheme.mutedText.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppTheme.mutedText.withValues(alpha: 0.9),
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                widget.controller.clear();
                widget.onChanged?.call('');
              },
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppTheme.mutedText.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

