import 'package:flutter/material.dart';
import '../../config/app_constants.dart';
import '../../config/app_theme.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onChanged;
  final Function()? onClear;
  final String? hintText;
  final TextInputAction textInputAction;

  const CustomSearchBar({
    required this.onChanged,
    this.onClear,
    this.hintText = 'Rechercher...',
    this.textInputAction = TextInputAction.search,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
    widget.onChanged(_controller.text);
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
        suffixIcon: _hasText
            ? IconButton(icon: const Icon(Icons.close), onPressed: _clear)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
