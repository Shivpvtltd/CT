import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color brandCyan = Color(0xFF00E5FF);
  static const Color brandGreen = Color(0xFF00FF88);
  static const Color brandDark = Color(0xFF050A14);
  static const Color brandSurface = Color(0xFF0D1526);
  static const Color brandCard = Color(0xFF111E33);
  static const Color brandBorder = Color(0xFF1E3050);

  static const Color activeGlow = Color(0xFF00E5FF);
  static const Color inactiveColor = Color(0xFF2A3F5F);
  static const Color disabledColor = Color(0xFF1A2840);
  static const Color errorColor = Color(0xFFFF4757);
  static const Color warningColor = Color(0xFFFFB142);

  // Light theme surfaces
  static const Color lightBg = Color(0xFFF0F4FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF8FAFF);
  static const Color lightBorder = Color(0xFFDDE5F5);

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: brandDark,
      colorScheme: const ColorScheme.dark(
        primary: brandCyan,
        secondary: brandGreen,
        surface: brandSurface,
        error: errorColor,
      ),
      textTheme: _buildTextTheme(Colors.white),
      cardTheme: CardThemeData(
        color: brandCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: brandBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0052CC),
        secondary: Color(0xFF00875A),
        surface: lightSurface,
        error: errorColor,
      ),
      textTheme: _buildTextTheme(const Color(0xFF050A14)),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Syne',
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: textColor,
        letterSpacing: -1.5,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Syne',
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -1.0,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Syne',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Syne',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Syne',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Syne',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor.withOpacity(0.75),
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor.withOpacity(0.55),
      ),
      labelLarge: TextStyle(
        fontFamily: 'Syne',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0.5,
      ),
    );
  }
}
