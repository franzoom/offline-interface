import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/homepage.dart';
import 'themes.dart';
import 'services/calendar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les locales françaises pour le formatage des dates
  await initializeDateFormatting('fr_FR', null);

  // Initialiser le Calendar global
  await CalendarService().init();

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
  DateTime _selectedDate = DateTime.now();

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

      // Charger la date sauvegardée ou utiliser la date du jour
      final savedDateMillis = prefs.getInt('selected_date');
      if (savedDateMillis != null) {
        _selectedDate = DateTime.fromMillisecondsSinceEpoch(savedDateMillis);
      }

      _isLoading = false;
    });
  }

  Future<void> _saveSelectedDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_date', date.millisecondsSinceEpoch);
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

  void updateSelectedDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _saveSelectedDate(date);
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
      ],
      locale: const Locale('fr', 'FR'),
      theme: AppThemes.lightTheme(
        fontFamily: bodyFontFamily,
        useSerifFont: _useSerifFont,
      ),
      darkTheme: AppThemes.darkTheme(
        fontFamily: bodyFontFamily,
        useSerifFont: _useSerifFont,
      ),
      themeMode: _themeMode,
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
        selectedDate: _selectedDate,
        onDateChanged: updateSelectedDate,
      ),
    );
  }
}
