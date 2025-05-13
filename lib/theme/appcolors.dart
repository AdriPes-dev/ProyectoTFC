import 'package:flutter/material.dart';

class AppColors {
  // Colores principales
  static const Color primaryBlue = Color(0xFF2196F3); // Azul
  static const Color gradientPurple = Color(0xFFFFC107); // Morado Color(0xFF9C27B0);
  static const Color textBlack = Colors.black;

  // Tema claro
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textBlack),
      bodyMedium: TextStyle(color: textBlack),
    ),
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: gradientPurple,
    ),
  );

  // Tema oscuro
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    colorScheme: ColorScheme.dark(
      primary: primaryBlue,
      secondary: gradientPurple,
    ),
  );
  static LinearGradient mainGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryBlue,
      gradientPurple,
    ],
  );
}
