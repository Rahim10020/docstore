import 'package:docstore/core/theme.dart';
import 'package:docstore/ui/screens/launch_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LaunchScreen shows logo and tagline', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const LaunchScreen(),
          ),
        ),
      );

      // Laisser le temps aux animations de se lancer
      await tester.pump(const Duration(milliseconds: 100));

      // Logo image
      expect(find.byType(Image), findsWidgets);

      // Tagline text (approximate match on key words)
      expect(find.textContaining('documents'), findsWidgets);
    });
  });
}
