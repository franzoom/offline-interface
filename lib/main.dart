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
  double _textScale = 1.0;
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
      _textScale = prefs.getDouble('text_scale') ?? 1.0;
      _isLoading = false;
    });
  }

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void toggleFont() {
    setState(() {
      _useSerifFont = !_useSerifFont;
    });
  }

  void updateTextScale(double scale) {
    setState(() {
      _textScale = scale;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final String? bodyFontFamily = _useSerifFont ? 'EBGaramond' : null;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liturgie des Heures',
      theme: ThemeData(
        primaryColor: const Color(0xFFD97706),
        scaffoldBackgroundColor: const Color(0xFFFFFBEB),
        fontFamily: bodyFontFamily,
        textTheme: TextTheme(
          displayLarge: TextStyle(fontFamily: bodyFontFamily),
          displayMedium: TextStyle(fontFamily: bodyFontFamily),
          displaySmall: TextStyle(fontFamily: bodyFontFamily),
          headlineLarge: TextStyle(fontFamily: bodyFontFamily),
          headlineMedium: TextStyle(fontFamily: bodyFontFamily),
          headlineSmall: TextStyle(fontFamily: bodyFontFamily),
          titleLarge: TextStyle(fontFamily: bodyFontFamily),
          titleMedium: TextStyle(fontFamily: bodyFontFamily),
          titleSmall: TextStyle(fontFamily: bodyFontFamily),
          bodyLarge: TextStyle(
            fontFamily: bodyFontFamily,
            fontSize: _useSerifFont ? 17.6 : 16, // 10% plus grand si serif
          ),
          bodyMedium: TextStyle(
            fontFamily: bodyFontFamily,
            fontSize: _useSerifFont ? 15.4 : 14,
          ),
          bodySmall: TextStyle(
            fontFamily: bodyFontFamily,
            fontSize: _useSerifFont ? 13.2 : 12,
          ),
          labelLarge: TextStyle(fontFamily: bodyFontFamily),
          labelMedium: TextStyle(fontFamily: bodyFontFamily),
          labelSmall: TextStyle(fontFamily: bodyFontFamily),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF78350F),
          elevation: 1,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFBBF24),
        scaffoldBackgroundColor: const Color(0xFF111827),
        fontFamily: bodyFontFamily,
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontFamily: bodyFontFamily, color: const Color(0xFFD1D5DB)),
          displayMedium: TextStyle(
              fontFamily: bodyFontFamily, color: const Color(0xFFD1D5DB)),
          displaySmall: TextStyle(
              fontFamily: bodyFontFamily, color: const Color(0xFFD1D5DB)),
          headlineLarge: TextStyle(
              fontFamily: bodyFontFamily, color: const Color(0xFFD1D5DB)),
          headlineMedium: TextStyle(
              fontFamily: bodyFontFamily, color: const Color(0xFFD1D5DB)),
          headlineSmall: TextStyle(
              fontFamily: bodyFontFamily, color: const Color(0xFFD1D5DB)),
          titleLarge: TextStyle(
              fontFamily: bodyFontFamily, color: const Color(0xFFD1D5DB)),
          titleMedium: TextStyle(
              fontFamily: bodyFontFamily, color: const Color(0xFFD1D5DB)),
          titleSmall: TextStyle(
              fontFamily: bodyFontFamily, color: const Color(0xFFD1D5DB)),
          bodyLarge: TextStyle(
            fontFamily: bodyFontFamily,
            fontSize: _useSerifFont ? 17.6 : 16,
            color: const Color(0xFFD1D5DB),
          ),
          bodyMedium: TextStyle(
            fontFamily: bodyFontFamily,
            fontSize: _useSerifFont ? 15.4 : 14,
            color: const Color(0xFFD1D5DB),
          ),
          bodySmall: TextStyle(
            fontFamily: bodyFontFamily,
            fontSize: _useSerifFont ? 13.2 : 12,
            color: const Color(0xFFD1D5DB),
          ),
          labelLarge: TextStyle(
              fontFamily: bodyFontFamily, color: const Color(0xFFD1D5DB)),
          labelMedium: TextStyle(
              fontFamily: bodyFontFamily, color: const Color(0xFFD1D5DB)),
          labelSmall: TextStyle(
              fontFamily: bodyFontFamily, color: const Color(0xFFD1D5DB)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F2937),
          foregroundColor: Color(0xFFFBBF24),
          elevation: 1,
        ),
      ),
      themeMode: _themeMode,
      // Appliquer le textScale global via MediaQuery
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(_textScale),
          ),
          child: child!,
        );
      },
      home: HomePage(
        themeMode: _themeMode,
        onToggleTheme: toggleTheme,
        useSerifFont: _useSerifFont,
        onToggleFont: toggleFont,
        textScale: _textScale,
        onTextScaleChanged: updateTextScale,
      ),
    );
  }
}
