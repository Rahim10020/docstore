import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/models/ue.dart';

class UeCard extends StatelessWidget {
  final Ue ue;
  final VoidCallback? onTap;
  final Widget? trailing;

  const UeCard({
    super.key,
    required this.ue,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ue.nom,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ue.description ?? 'Nom de l\'UE',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ue.anneeEnseignement.isNotEmpty
                          ? ue.anneeEnseignement.join(', ')
                          : 'Année',
                      style: const TextStyle(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  trailing ?? const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

