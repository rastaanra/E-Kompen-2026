import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFB71C1C);
  static const Color lightRed = Color(0xFFEF9A9A);
  static const Color backgroundCream = Color(0xFFF5EFE6);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color approved = Color(0xFF4CAF50);
  static const Color pending = Color(0xFFFF9800);
  static const Color tagBeige = Color(0xFFF0E6D3);

  static ThemeData get theme => ThemeData(
        primaryColor: primaryRed,
        scaffoldBackgroundColor: backgroundCream,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
          primary: primaryRed,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        useMaterial3: true,
      );
}