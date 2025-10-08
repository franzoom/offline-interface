import 'package:intl/intl.dart';

class DateUtils {
  /// Formate une date en français au format "mercredi 9 octobre 2025"
  static String formatDateFrench(DateTime date) {
    final formatter = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    String formatted = formatter.format(date);

    // Capitaliser la première lettre du jour
    return formatted[0].toUpperCase() + formatted.substring(1);
  }
}
