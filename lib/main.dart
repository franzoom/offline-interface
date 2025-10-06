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

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liturgie des Heures',
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFFD97706),
        scaffoldBackgroundColor: const Color(0xFFFFFBEB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF78350F),
          elevation: 1,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFFBBF24),
        scaffoldBackgroundColor: const Color(0xFF111827),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F2937),
          foregroundColor: Color(0xFFFBBF24),
          elevation: 1,
        ),
      ),
      themeMode: _themeMode,
      home: HomePage(themeMode: _themeMode, onToggleTheme: toggleTheme),
    );
  }
}
