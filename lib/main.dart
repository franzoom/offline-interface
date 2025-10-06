import 'package:flutter/material.dart';
import 'pages/homepage.dart';

void main() {
  runApp(const BreviaireApp());
}

class BreviaireApp extends StatefulWidget {
  const BreviaireApp({Key? key}) : super(key: key);

  @override
  State<BreviaireApp> createState() => _BreviaireAppState();
}

class _BreviaireAppState extends State<BreviaireApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _useSerifFont = true; // true = Georgia (serif), false = sans-serif

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  void toggleFont() {
    setState(() {
      _useSerifFont = !_useSerifFont;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? fontFamily = _useSerifFont ? 'Georgia' : null;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liturgie des Heures',
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFFD97706),
        scaffoldBackgroundColor: const Color(0xFFFFFBEB),
        textTheme: ThemeData.light().textTheme.apply(fontFamily: fontFamily),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF78350F),
          elevation: 1,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFFBBF24),
        scaffoldBackgroundColor: const Color(0xFF111827),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: fontFamily),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F2937),
          foregroundColor: Color(0xFFFBBF24),
          elevation: 1,
        ),
      ),
      themeMode: _themeMode,
      home: HomePage(
        themeMode: _themeMode,
        onToggleTheme: toggleTheme,
        useSerifFont: _useSerifFont,
        onToggleFont: toggleFont,
      ),
    );
  }
}
