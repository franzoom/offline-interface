import 'package:flutter/material.dart';
import '../styles.dart';

class InformationsPage extends StatelessWidget {
  const InformationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitreText('Bienvenue dans la Liturgie des Heures'),
          SizedBox(height: 12),
          SousTitreText('Application du Bréviaire'),
          SizedBox(height: 20),
          CorpsText(
            'Cette application vous permet de suivre les différents offices de la journée selon la tradition de la prière liturgique de l\'Église.',
          ),
          SizedBox(height: 24),
          RubriqueText('Les offices disponibles :'),
          SizedBox(height: 12),
          CorpsText('• Laudes - Prière du matin'),
          SizedBox(height: 8),
          CorpsText(
            '• Office des Lectures - Office de lecture spirituelle',
          ),
          SizedBox(height: 8),
          CorpsText('• Milieu du Jour - Prière de la mi-journée'),
          SizedBox(height: 8),
          CorpsText('• Vêpres - Prière du soir'),
          SizedBox(height: 8),
          CorpsText('• Complies - Prière avant le repos'),
        ],
      ),
    );
  }
}
