import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import 'notification_icon.dart';

class DocStoreHeader extends ConsumerWidget {
  final String pageTitle;
  final String? subtitle;
  final Widget? trailing;

  const DocStoreHeader({
    super.key,
    required this.pageTitle,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'DocStore',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            // Notification icon
            const NotificationIcon(),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pageTitle,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ],
    );
  }
}
