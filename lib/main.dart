import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BreviaireApp());
}

class BreviaireApp extends StatefulWidget {
  const BreviaireApp({Key? key}) : super(key: key);

  @override
  State<BreviaireApp> createState() => _BreviaireAppState();
}

class _BreviaireAppState extends State<BreviaireApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _useSerifFont = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final isDark = prefs.getBool('is_dark_mode') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _useSerifFont = prefs.getBool('use_serif_font') ?? true;
      _isLoading = false;
    });
  }

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
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

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
