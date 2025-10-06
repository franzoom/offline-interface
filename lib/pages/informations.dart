import 'package:flutter/material.dart';
import '../styles.dart';

class InformationsPage extends StatelessWidget {
  const InformationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitreText('Bienvenue dans la Liturgie des Heures'),
          const SizedBox(height: 12),
          const SousTitreText('Application du Bréviaire'),
          const SizedBox(height: 20),
          const CorpsText(
            'Cette application vous permet de suivre les différents offices de la journée selon la tradition de la prière liturgique de l\'Église.',
          ),
          const SizedBox(height: 24),
          const RubriqueText('Les offices disponibles :'),
          const SizedBox(height: 12),
          const CorpsText('• Laudes - Prière du matin'),
          const SizedBox(height: 8),
          const CorpsText(
            '• Office des Lectures - Office de lecture spirituelle',
          ),
          const SizedBox(height: 8),
          const CorpsText('• Milieu du Jour - Prière de la mi-journée'),
          const SizedBox(height: 8),
          const CorpsText('• Vêpres - Prière du soir'),
          const SizedBox(height: 8),
          const CorpsText('• Complies - Prière avant le repos'),
        ],
      ),
    );
  }
}
