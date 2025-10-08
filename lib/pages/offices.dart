import 'package:flutter/material.dart';
import '../styles.dart';
import '../services/calendar_service.dart';

// Page Office (exemple générique)
class OfficePage extends StatelessWidget {
  final String title;
  final DateTime selectedDate;

  const OfficePage({
    Key? key,
    required this.title,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Récupérer les informations du jour depuis le Calendar
    final dayContent = CalendarService().getDayContent(selectedDate);
    final celebrations = CalendarService().getSortedItemsForDay(selectedDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitreText(title),
          if (celebrations.isNotEmpty) ...[
            const SizedBox(height: 8),
            ReferenceBibliqueText(celebrations.first.value),
          ],
          const SizedBox(height: 24),
          const RubriqueText('Introduction'),
          const SizedBox(height: 12),
          const CorpsText('Dieu, viens à mon aide. Seigneur, à notre secours.'),
          const SizedBox(height: 24),
          const SousTitreText('Hymne'),
          const SizedBox(height: 12),
          const CorpsText('[Le texte de l\'hymne sera affiché ici]'),
          const SizedBox(height: 24),
          const SousTitreText('Psaume'),
          const SizedBox(height: 8),
          const ReferenceBibliqueText('Psaume 95 (94)'),
          const SizedBox(height: 12),
          const CorpsText(
            'Venez, crions de joie pour le Seigneur,\n'
            'acclamons notre Rocher, notre salut !\n'
            'Allons jusqu\'à lui en rendant grâce,\n'
            'par nos hymnes de fête acclamons-le !',
          ),
          const SizedBox(height: 24),
          const RubriqueText('Lecture brève'),
          const SizedBox(height: 8),
          const ReferenceBibliqueText('1 Thessaloniciens 5, 16-18'),
          const SizedBox(height: 12),
          const CorpsText(
            'Soyez toujours dans la joie, priez sans relâche, rendez grâce en toute circonstance.',
          ),
          const SizedBox(height: 24),
          const SousTitreText('Cantique de Zacharie'),
          const SizedBox(height: 8),
          const ReferenceBibliqueText('Luc 1, 68-79'),
          const SizedBox(height: 12),
          const CorpsText('[Le texte du cantique sera affiché ici]'),
          const SizedBox(height: 24),
          const RubriqueText('Prière finale'),
          const SizedBox(height: 12),
          const CorpsText('[La prière de conclusion sera affichée ici]'),
          if (dayContent != null) ...[
            const SizedBox(height: 32),
            const SousTitreText('Informations liturgiques'),
            const SizedBox(height: 12),
            CorpsText('Temps liturgique : ${dayContent.liturgicalTime}'),
            const SizedBox(height: 8),
            CorpsText('Couleur : ${dayContent.liturgicalColor}'),
          ],
        ],
      ),
    );
  }
}
