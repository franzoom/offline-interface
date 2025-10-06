import 'package:flutter/material.dart';

class AppThemes {
  // Fonction pour créer le thème clair
  static ThemeData lightTheme({
    required String? fontFamily,
    required bool useSerifFont,
  }) {
    return ThemeData(
      primaryColor: const Color(0xFFD97706),
      scaffoldBackgroundColor: const Color(0xFFFFFBEB),
      fontFamily: fontFamily,
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: fontFamily),
        displayMedium: TextStyle(fontFamily: fontFamily),
        displaySmall: TextStyle(fontFamily: fontFamily),
        headlineLarge: TextStyle(fontFamily: fontFamily),
        headlineMedium: TextStyle(fontFamily: fontFamily),
        headlineSmall: TextStyle(fontFamily: fontFamily),
        titleLarge: TextStyle(fontFamily: fontFamily),
        titleMedium: TextStyle(fontFamily: fontFamily),
        titleSmall: TextStyle(fontFamily: fontFamily),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: useSerifFont ? 17.6 : 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: useSerifFont ? 15.4 : 14,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: useSerifFont ? 13.2 : 12,
        ),
        labelLarge: TextStyle(fontFamily: fontFamily),
        labelMedium: TextStyle(fontFamily: fontFamily),
        labelSmall: TextStyle(fontFamily: fontFamily),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF78350F),
        elevation: 1,
      ),
    );
  }

  // Fonction pour créer le thème sombre
  static ThemeData darkTheme({
    required String? fontFamily,
    required bool useSerifFont,
  }) {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFFBBF24),
      scaffoldBackgroundColor: const Color(0xFF111827),
      fontFamily: fontFamily,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFFD1D5DB),
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFFD1D5DB),
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFFD1D5DB),
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFFD1D5DB),
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFFD1D5DB),
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFFD1D5DB),
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFFD1D5DB),
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFFD1D5DB),
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFFD1D5DB),
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: useSerifFont ? 17.6 : 16,
          color: const Color(0xFFD1D5DB),
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: useSerifFont ? 15.4 : 14,
          color: const Color(0xFFD1D5DB),
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: useSerifFont ? 13.2 : 12,
          color: const Color(0xFFD1D5DB),
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFFD1D5DB),
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFFD1D5DB),
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamily,
          color: const Color(0xFFD1D5DB),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2937),
        foregroundColor: Color(0xFFFBBF24),
        elevation: 1,
      ),
    );
  }

  // Couleurs de l'app (pour référence facile)
  static const Color amberLight = Color(0xFFD97706);
  static const Color amberDark = Color(0xFFFBBF24);
  static const Color brownDark = Color(0xFF78350F);
  static const Color creamBackground = Color(0xFFFFFBEB);
  static const Color darkBackground = Color(0xFF111827);
}
