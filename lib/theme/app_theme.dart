import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color darkBlue = Color(0xFF1E3A8A);
  static const Color lightBlue = Color(0xFF60A5FA);
  
  // Gradient Colors
  static const List<Color> gradientColors = [
    Color(0xFF1E3A8A),
    Color(0xFF3B82F6),
    Color(0xFF60A5FA),
  ];
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E3A8A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textWhite = Colors.white;
  
  // Background Colors
  static const Color backgroundLight = Colors.white;
  static const Color backgroundDark = Color(0xFF111827);
  
  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: textWhite,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: lightBlue,
      ),
    );
  }
  
  // Gradient Decoration
  static BoxDecoration get gradientDecoration {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ),
    );
  }
  
  // Card Decoration
  static BoxDecoration cardDecoration({
    Color? color,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      color: color ?? backgroundLight,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

