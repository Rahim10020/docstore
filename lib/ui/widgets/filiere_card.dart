import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/models/filiere.dart';

class FiliereCard extends StatelessWidget {
  final Filiere filiere;
  final VoidCallback? onTap;
  final Widget? trailing;

  const FiliereCard({
    super.key,
    required this.filiere,
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
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: const BoxDecoration(
                gradient: AppTheme.establishmentCardGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Text(
                filiere.nom,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filiere.description ?? 'Nom de la filiere',
                    style: TextStyle(
                      color: AppTheme.textPrimary.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      filiere.parcours,
                      style: const TextStyle(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Type de licence',
                        style: TextStyle(
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

