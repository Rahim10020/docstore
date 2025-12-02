import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const CustomErrorWidget({
    required this.message,
    this.onRetry,
    this.retryLabel = 'Réessayer',
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.errorRed),
            const SizedBox(height: 16),
            Text(
              'Une erreur est survenue',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel ?? 'Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
