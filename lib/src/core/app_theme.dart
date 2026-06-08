import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.deepTeal,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.deepTeal),
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16.0, height: 1.4),
      titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.softGreen,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.softGreen, brightness: Brightness.dark),
    scaffoldBackgroundColor: const Color(0xFF071422),
    useMaterial3: true,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16.0, height: 1.4, color: Colors.white),
      titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.white),
    ),
  );
}
