import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color neonAccent = Color(0xFF38BDF8);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: neonAccent,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        bodyLarge: const TextStyle(color: textPrimary),
        bodyMedium: const TextStyle(color: textSecondary),
      ),
      cardTheme: const CardThemeData(
        color: glassWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}
