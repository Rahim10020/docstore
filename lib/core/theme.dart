import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Couleurs principales
  static const Color primaryBlue = Color(0xFF3b82f6);
  static const Color primaryIndigo = Color(0xFF4f46e5);
  static const Color primaryOrange = Color(0xFFf97316);
  static const Color primaryYellow = Color(0xFFeab308);
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color secondaryPurple = Color(0xFF9333EA);
  static const Color accentRed = Color(0xFFFF4B5C);
  static const Color accentDeepRed = Color(0xFFE11D48);
  static const Color backgroundColorLight = Color(0xFFf8fafc);
  static const Color backgroundColorDark = Color(0xFFf1f5f9);
  static const Color textPrimary = Color(0xFF1f2937);
  static const Color textSecondary = Color(0xFF374151);
  static const Color successColor = Color(0xFF22c55e);
  static const Color errorColor = Color(0xFFef4444);
  static const Color mutedText = Color(0xFF9CA3AF);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: backgroundColorLight,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPurple,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF111827),
    textTheme: GoogleFonts.interTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F2937),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1F2937),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Gradients
  static const LinearGradient schoolGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryIndigo],
  );

  static const LinearGradient concoursGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryOrange, primaryYellow],
  );

  static const LinearGradient establishmentCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, secondaryPurple],
  );

  static const LinearGradient concoursCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentRed, accentDeepRed],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundColorLight, backgroundColorDark],
  );
}
