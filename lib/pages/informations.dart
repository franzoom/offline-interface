import 'package:flutter/material.dart';
import '../styles.dart';
import '../services/calendar_service.dart';
import 'package:offline_liturgy/offline_liturgy.dart';

class InformationsPage extends StatelessWidget {
  final DateTime selectedDate;

  const InformationsPage({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  String _getLiturgicalColorName(String color) {
    switch (color) {
      case 'white':
        return 'Blanc';
      case 'red':
        return 'Rouge';
      case 'green':
        return 'Vert';
      case 'purple':
        return 'Violet';
      case 'rose':
        return 'Rose';
      default:
        return color;
    }
  }

  String _getLiturgicalTimeName(String time) {
    switch (time) {
      case 'Advent':
        return 'Temps de l\'Avent';
      case 'Christmas':
        return 'Temps de Noël';
      case 'Lent':
        return 'Temps du Carême';
      case 'LentFeriale':
        return 'Carême (férie)';
      case 'Easter':
        return 'Temps Pascal';
      case 'Ordinary':
        return 'Temps Ordinaire';
      default:
        return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Récupérer les informations du jour depuis le Calendar
    final dayContent = CalendarService().getDayContent(selectedDate);
    final sortedItems = CalendarService().getSortedItemsForDay(selectedDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitreText('Informations liturgiques'),
          const SizedBox(height: 20),
          if (dayContent == null)
            Card(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isDark
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFFD97706),
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune donnée disponible pour cette date',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? const Color(0xFFD1D5DB)
                            : const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Veuillez sélectionner une localisation dans les paramètres.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte principale
                Card(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.church,
                              color: isDark
                                  ? const Color(0xFFFBBF24)
                                  : const Color(0xFFD97706),
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Année liturgique ${dayContent.liturgicalYear}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFFFBBF24)
                                      : const Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.wb_twilight,
                          label: 'Temps liturgique',
                          value:
                              _getLiturgicalTimeName(dayContent.liturgicalTime),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.palette,
                          label: 'Couleur',
                          value: _getLiturgicalColorName(
                              dayContent.liturgicalColor),
                          isDark: isDark,
                        ),
                        if (dayContent.breviaryWeek != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            icon: Icons.calendar_view_week,
                            label: 'Semaine du psautier',
                            value: dayContent.breviaryWeek.toString(),
                            isDark: isDark,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Célébrations du jour
                const SousTitreText('Célébrations du jour'),
                const SizedBox(height: 12),

                if (sortedItems.isEmpty)
                  Card(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CorpsText('Aucune célébration spécifique'),
                    ),
                  )
                else
                  ...sortedItems.map((item) {
                    return Card(
                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? const Color(0xFFFBBF24)
                                        : const Color(0xFFD97706))
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  item.key.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFFFBBF24)
                                        : const Color(0xFFD97706),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CorpsText(item.value),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                const SizedBox(height: 24),
                const RubriqueText('Les offices disponibles :'),
                const SizedBox(height: 12),
                const CorpsText('• Laudes - Prière du matin'),
                const SizedBox(height: 8),
                const CorpsText(
                    '• Office des Lectures - Office de lecture spirituelle'),
                const SizedBox(height: 8),
                const CorpsText('• Milieu du Jour - Prière de la mi-journée'),
                const SizedBox(height: 8),
                const CorpsText('• Vêpres - Prière du soir'),
                const SizedBox(height: 8),
                const CorpsText('• Complies - Prière avant le repos'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
        ),
        const SizedBox(width: 8),
        Text(
          '$label : ',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }
}
