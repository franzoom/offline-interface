import 'package:offline_liturgy/classes/calendar_class.dart'; // Ajustez le chemin selon votre package

class CalendarService {
  // Singleton
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  // Variable calendar globale
  Calendar? _offlineCalendar;

  // Getter pour accéder au calendar
  Calendar? get offlineCalendar => _offlineCalendar;

  // Initialiser le calendar
  Future<void> init() async {
    _offlineCalendar = Calendar();
    // Ajoutez ici toute initialisation nécessaire
    print('Calendar initialisé');
  }

  // Méthode pour mettre à jour le calendar si besoin
  void updateCalendar(Calendar newCalendar) {
    _offlineCalendar = newCalendar;
  }
}
