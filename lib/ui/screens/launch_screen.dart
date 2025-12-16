import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import 'app_shell.dart';

class LaunchScreen extends ConsumerStatefulWidget {
  const LaunchScreen({super.key});

  @override
  ConsumerState<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends ConsumerState<LaunchScreen>
    with SingleTickerProviderStateMixin {
  static const _minDisplayDuration = Duration(milliseconds: 1600);

  late final AnimationController _controller;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _logoScaleAnimation = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Ne pas démarrer la navigation auto pendant les tests pour éviter les timers pendants.
    const bool isTestEnv = bool.fromEnvironment('FLUTTER_TEST');
    if (!isTestEnv) {
      _navigateToHome();
    }
  }

  Future<void> _navigateToHome() async {
    await Future<void>.delayed(_minDisplayDuration);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: const DocStoreAppShell(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final headlineStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppTheme.textPrimary,
        );

    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isDark
              ? Colors.white.withOpacity(0.72)
              : AppTheme.mutedText,
        );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                // Top-right subtle pill with app name
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isDark ? 0.06 : 0.55),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withOpacity(isDark ? 0.08 : 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.successColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'DocStore EPL',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white.withOpacity(0.9)
                                    : AppTheme.textPrimary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 2),

                // Animated logo + title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(isDark ? 0.04 : 0.85),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(22.0),
                            child: Image.asset(
                              'assets/icons/launch.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Vos documents, toujours accessibles',
                          textAlign: TextAlign.center,
                          style: headlineStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Consultez, sauvegardez et partagez les sujets, corrections et ressources académiques de l'EPL.",
                          textAlign: TextAlign.center,
                          style: subtitleStyle,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Bottom loading + hint
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark
                                    ? AppTheme.primaryPurple
                                    : AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Initialisation de votre espace documents…',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.7)
                                      : AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Connexion sécure à Appwrite & préchargement des métadonnées.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? Colors.white.withOpacity(0.5)
                                  : AppTheme.mutedText,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
