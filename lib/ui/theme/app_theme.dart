import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color lightBackground = Color(0xFFF8F9FA); // Off-white
  static const Color cardColor = Color(0xFFFFFFFF); // Pure white
  static const Color accentColor = Color(0xFF111827); // Deep gray/black
  static const Color textPrimary = Color(0xFF111827); // Deep gray/black
  static const Color textSecondary = Color(0xFF6B7280); // Gray
  static const Color borderLight = Color(0xFFE5E7EB); // Very subtle gray

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: accentColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.w800, letterSpacing: -1.0),
        bodyLarge: const TextStyle(color: textPrimary, fontSize: 18, height: 1.5, fontWeight: FontWeight.w500),
        bodyMedium: const TextStyle(color: textSecondary, fontSize: 16),
      ),
      cardTheme: const CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}
