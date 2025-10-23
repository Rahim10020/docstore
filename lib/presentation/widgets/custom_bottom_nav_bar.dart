import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: const Color(0xFF8B5CF6),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Écoles'),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'Concours',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
      ],
    );
  }
}
