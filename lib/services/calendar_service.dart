import 'package:shared_preferences/shared_preferences.dart';
import 'package:offline_liturgy/offline_liturgy.dart';

class CalendarService {
  // Singleton pattern
  static final CalendarService _instance = CalendarService._internal();

  factory CalendarService() {
    return _instance;
  }

  CalendarService._internal();

  Calendar? _calendar;
  String? _currentLocation;
  Set<int> _loadedYears = {};

  Calendar get calendar => _calendar ?? Calendar();

  Future<void> init() async {
    _calendar = Calendar();
    final prefs = await SharedPreferences.getInstance();
    _currentLocation = prefs.getString('selected_location_id');

    // Charger l'année courante au démarrage
    if (_currentLocation != null) {
      await ensureYearLoaded(DateTime.now().year, _currentLocation!);
    }
  }

  /// Vérifie si une année est déjà chargée dans le calendrier
  bool isYearLoaded(int year) {
    return _loadedYears.contains(year);
  }

  /// S'assure qu'une année est chargée pour une localisation donnée
  Future<void> ensureYearLoaded(int year, String location) async {
    // Si l'année est déjà chargée et la localisation n'a pas changé, ne rien faire
    if (_loadedYears.contains(year) && _currentLocation == location) {
      return;
    }

    // Si la localisation a changé, recharger tout
    if (_currentLocation != location) {
      _calendar = Calendar();
      _loadedYears.clear();
      _currentLocation = location;
    }

    // Charger l'année
    print(
        'Chargement du calendrier pour l\'année $year et la localisation $location');

    try {
      final filledCalendar = calendarFill(_calendar!, year, location);
      _calendar!.calendarData.addAll(filledCalendar.calendarData);
      _loadedYears.add(year);
      print('Calendrier chargé avec succès pour l\'année $year');
    } catch (e) {
      print('Erreur lors du chargement du calendrier: $e');
    }
  }

  /// Met à jour complètement le calendrier (utilisé dans settings)
  void updateCalendar(Calendar newCalendar) {
    _calendar = newCalendar;
    _loadedYears.clear();
    // Analyser les années présentes dans le nouveau calendrier
    _calendar!.calendarData.keys.forEach((date) {
      _loadedYears.add(date.year);
    });
  }

  /// Récupère le contenu d'un jour spécifique
  DayContent? getDayContent(DateTime date) {
    return _calendar?.getDayContent(date);
  }

  /// Récupère les célébrations triées pour un jour
  List<MapEntry<int, String>> getSortedItemsForDay(DateTime date) {
    return _calendar?.getSortedItemsForDay(date) ?? [];
  }

  /// Met à jour la localisation courante
  Future<void> updateLocation(String location) async {
    if (_currentLocation != location) {
      _currentLocation = location;
      _calendar = Calendar();
      _loadedYears.clear();

      // Recharger l'année courante
      await ensureYearLoaded(DateTime.now().year, location);

      // Sauvegarder la localisation
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_location_id', location);
    }
  }

  /// Nettoie le calendrier (utile pour debug)
  void clear() {
    _calendar = Calendar();
    _loadedYears.clear();
    _currentLocation = null;
  }
}
