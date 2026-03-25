import 'package:flutter/material.dart';

/// Modern Dark Theme Configuration
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  primaryColor: const Color(0xff6A5AE0),
  scaffoldBackgroundColor: const Color(0xff121212),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xff6A5AE0),
    brightness: Brightness.dark,
    primary: const Color(0xff6A5AE0),
    surface: const Color(0xff1E1E1E),
    onSurface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xff1E1E1E),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xff1E1E1E),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return Colors.white;
      return null;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return const Color(0xff6A5AE0);
      return null;
    }),
  ),
);
