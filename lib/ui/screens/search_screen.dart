import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../widgets/search_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoundedSearchBar(
          controller: _controller,
          hint: 'Rechercher tous...',
          onChanged: (_) {},
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Center(
            child: Text(
              'Commencez votre recherche',
              style: TextStyle(
                color: AppTheme.mutedText,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

