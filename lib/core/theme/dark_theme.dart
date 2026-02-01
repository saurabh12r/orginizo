import 'package:flutter/material.dart';

import '../constants/colors.dart';

ThemeData get darkTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: OrColors.darkCard,
    colorScheme: ColorScheme.dark(
      primary: OrColors.primaryGreen,
      onPrimary: OrColors.textDark,
      surface: OrColors.darkCard,
      onSurface: OrColors.lightBg,
      error: Colors.red.shade400,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: OrColors.darkCard,
      foregroundColor: OrColors.lightBg,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: OrColors.primaryGreen,
        foregroundColor: OrColors.textDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: OrColors.darkCard,
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
