import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple provider that always exposes light theme.
// Dark mode is disabled for now but this keeps a stable API
// in case other parts of the app still read themeModeProvider.
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ThemeMode.light;
});
