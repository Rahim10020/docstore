import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme.dart';

class DocStoreBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const DocStoreBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  State<DocStoreBottomNavBar> createState() => _DocStoreBottomNavBarState();
}

class _DocStoreBottomNavBarState extends State<DocStoreBottomNavBar>
    with SingleTickerProviderStateMixin {
  static const int _itemCount = 5;

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      // outer background of the bar
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 1,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: SizedBox(
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sliding glass highlight
            Positioned.fill(
              child: LayoutBuilder(builder: (context, constraints) {
                // compute alignment x from index
                final step = 2.0 / (_itemCount - 1);
                final alignX = -1.0 + widget.currentIndex * step;
                final isCenter = widget.currentIndex == 2;

                final double highlightWidth = isCenter ? 60 : 72;
                final double highlightHeight = isCenter ? 60 : 53;
                final double borderRadius = isCenter ? 36 : 30;

                return AnimatedAlign(
                  alignment: Alignment(alignX, 0),
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: (constraints.maxWidth - _itemCount * highlightWidth) / (_itemCount * 2).clamp(0.0, double.infinity)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 320),
                          width: highlightWidth,
                          height: highlightHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppTheme.primaryYellow, AppTheme.primaryYellow],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                              width: 0.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            // Row of items on top
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AnimatedNavItem(
                  iconWidget: SvgPicture.asset(
                    'assets/icons/ecoles.svg',
                    width: 26,
                    height: 26,
                  ),
                  label: 'Ecoles',
                  isActive: widget.currentIndex == 0,
                  onTap: () => widget.onItemSelected(0),
                ),
                _AnimatedNavItem(
                  iconWidget: SvgPicture.asset(
                    'assets/icons/concours.svg',
                    width: 26,
                    height: 26,
                  ),
                  label: 'Concours',
                  isActive: widget.currentIndex == 1,
                  onTap: () => widget.onItemSelected(1),
                ),
                _AnimatedCenterButton(
                  isActive: widget.currentIndex == 2,
                  onTap: () => widget.onItemSelected(2),
                ),
                _SavedAnimatedNavItem(
                  isActive: widget.currentIndex == 3,
                  onTap: () => widget.onItemSelected(3),
                ),
                _AnimatedNavItem(
                  iconWidget: SvgPicture.asset(
                    'assets/icons/settings.svg',
                    width: 26,
                    height: 26,
                  ),
                  label: 'Param',
                  isActive: widget.currentIndex == 4,
                  onTap: () => widget.onItemSelected(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedNavItem extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.iconWidget,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppTheme.textPrimary;
    final inactiveColor = AppTheme.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: isActive ? 1.12 : 1.0, end: isActive ? 1.12 : 1.0),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(isActive ? activeColor : inactiveColor, BlendMode.srcIn),
                    child: child,
                  ),
                );
              },
              child: iconWidget,
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 260),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedAnimatedNavItem extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _SavedAnimatedNavItem({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: isActive ? 1.12 : 1.0, end: isActive ? 1.12 : 1.0),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: SvgPicture.asset(
                'assets/icons/saved.svg',
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(AppTheme.textPrimary, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 260),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
              child: const Text('Favoris'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCenterButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _AnimatedCenterButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final activeColor = AppTheme.primaryPurple;
    final iconColor = isActive ? activeColor : AppTheme.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isActive ? 50 : 46,
        height: isActive ? 50 : 46,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: AnimatedScale(
            scale: isActive ? 1.06 : 1.0,
            duration: const Duration(milliseconds: 260),
            child: Icon(Icons.search, size: 26, color: iconColor),
          ),
        ),
      ),
    );
  }
}
