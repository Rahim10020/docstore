import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme.dart';

class DocStoreBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const DocStoreBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            iconWidget: SvgPicture.asset(
              'assets/icons/ecoles.svg',
              width: 24,
              height: 24,
            ),
            label: 'Ecoles',
            isActive: currentIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          _NavItem(
            iconWidget: SvgPicture.asset(
              'assets/icons/concours.svg',
              width: 24,
              height: 24,
            ),
            label: 'Concours',
            isActive: currentIndex == 1,
            onTap: () => onItemSelected(1),
          ),
          _NavItem(
            iconWidget: SvgPicture.asset(
              'assets/icons/search.svg',
              width: 24,
              height: 24,
            ),
            label: 'Recherche',
            isActive: currentIndex == 2,
            onTap: () => onItemSelected(2),
          ),
          _SavedNavItem(
            isActive: currentIndex == 3,
            onTap: () => onItemSelected(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.iconWidget,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.primaryPurple : AppTheme.mutedText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            child: iconWidget,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedNavItem extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _SavedNavItem({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.primaryPurple : AppTheme.mutedText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            isActive ? 'assets/icons/saved-fill.svg' : 'assets/icons/saved.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(height: 4),
          Text(
            'Sauvegardés',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
