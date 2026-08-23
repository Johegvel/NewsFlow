import 'package:flutter/material.dart';

class AppTheme {
  static const String sansFont = 'Geist';
  static const String editorialFont = 'InstrumentSerif';

  static const Color darkBackground = Color(0xFF0B0E14);
  static const Color surfaceColor = Color(0xFF131823);
  static const Color borderColor = Color(0xFF1E2638);
  static const Color amberAccent = Color(0xFFFFB800);
  static const Color textPrimary = Colors.white;
  static const Color bodyText = Color(0xFFCBD5E1);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color destructive = Color(0xFFFF4545);

  static TextStyle editorial({
    double fontSize = 24,
    Color color = textPrimary,
    double height = 1.12,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return TextStyle(
      fontFamily: editorialFont,
      fontSize: fontSize,
      color: color,
      height: height,
      fontStyle: fontStyle,
      fontWeight: FontWeight.w400,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: sansFont,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: amberAccent,
      canvasColor: darkBackground,
      cardColor: surfaceColor,
      colorScheme: const ColorScheme.dark(
        primary: amberAccent,
        secondary: amberAccent,
        surface: surfaceColor,
        onPrimary: Colors.black,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: sansFont,
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: bodyText, fontSize: 15, height: 1.5),
        bodyMedium: TextStyle(color: bodyText, fontSize: 14, height: 1.45),
        bodySmall: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
        labelLarge: TextStyle(fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: amberAccent, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: amberAccent,
          foregroundColor: darkBackground,
          disabledBackgroundColor: amberAccent.withValues(alpha: 0.45),
          disabledForegroundColor: darkBackground.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderColor),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: amberAccent,
        foregroundColor: Colors.black,
        elevation: 6,
      ),
      useMaterial3: true,
    );
  }
}
