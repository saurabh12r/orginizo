import 'package:flutter/material.dart';

import '../constants/colors.dart';

ThemeData get lightTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: OrColors.bg,
    colorScheme: ColorScheme.light(
      primary: OrColors.primaryGreen,
      onPrimary: OrColors.textDark,
      surface: OrColors.bg,
      onSurface: OrColors.textDark,
      error: Colors.red.shade700,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: OrColors.bg,
      foregroundColor: OrColors.textDark,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: OrColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: OrColors.primaryGreen, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: const TextStyle(color: OrColors.textGrey),
    ),
  );
}
