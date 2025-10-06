import 'package:flutter/material.dart';
import '../styles.dart';
import '../services/calendar_service.dart';
import 'package:offline_liturgy/offline_liturgy.dart';

class Complines extends StatefulWidget {
  final String title;
  const Complines({Key? key, required this.title}) : super(key: key);

  @override
  State<Complines> createState() => _CompliesState();
}

class _CompliesState extends State<Complines>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool hasPsalm2 = true;
  Map<String, Compline>? _complineData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: hasPsalm2 ? 7 : 6, vsync: this);
    _loadComplinesData();
  }

  void _loadComplinesData() {
    // Accéder au Calendar global via CalendarService
    final calendar = CalendarService().offlineCalendar;

    if (calendar != null) {
      print('Calendar disponible pour les Complies');

      // Obtenir la date actuelle
      final now = DateTime.now();
      final dateString =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // TODO: Récupérer la région depuis les préférences ou localisation
      final region = 'france'; // À remplacer par la vraie valeur

      // Générer les données des Complies
      _complineData =
          getNewOfflineLiturgy('compline', dateString, region, calendar);

      print('Données des Complies chargées : ${_complineData?.keys}');
    } else {
      print('Calendar non disponible');
    }
  }

  Map<String, Compline> getNewOfflineLiturgy(
      String type, String date, String region, Calendar calendar) {
    print("getNewOfflineCompline appelé pour $type, $date, $region");
    DateTime dateTime = DateTime.parse(date);
    Map<String, ComplineDefinition> complineDefinitionResolved =
        complineDefinitionResolution(calendar, dateTime, region);
    Map<String, Compline> complineTextCompiled =
        complineTextCompilation(complineDefinitionResolved);
    return complineTextCompiled;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Barre d'onglets
        Container(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor:
                isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
            labelColor:
                isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F),
            unselectedLabelColor:
                isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            tabs: [
              const Tab(text: 'Introduction'),
              const Tab(text: 'Hymne'),
              const Tab(text: 'Psaume 1'),
              if (hasPsalm2) const Tab(text: 'Psaume 2'),
              const Tab(text: 'Lecture'),
              const Tab(text: 'Cantique'),
              const Tab(text: 'Oraison'),
            ],
          ),
        ),
        // Contenu des onglets
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Introduction
              _buildTabContent(
                context,
                children: [
                  TitreText(widget.title),
                  const SizedBox(height: 24),
                  const SousTitreText('Introduction'),
                  const SizedBox(height: 12),
                  const CorpsText(
                    'Dieu, viens à mon aide. Seigneur, à notre secours.',
                  ),
                  const SizedBox(height: 12),
                  const CorpsText(
                    'Gloire au Père, et au Fils, et au Saint-Esprit,\n'
                    'au Dieu qui est, qui était, et qui vient,\n'
                    'pour les siècles des siècles. Amen. Alléluia.',
                  ),
                ],
              ),
              // Hymne
              _buildTabContent(
                context,
                children: [
                  const SousTitreText('Hymne'),
                  const SizedBox(height: 12),
                  CorpsText(_getHymnText()),
                ],
              ),
              // Psaume 1
              _buildTabContent(
                context,
                children: [
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
                ],
              ),
              // Psaume 2 (conditionnel)
              if (hasPsalm2)
                _buildTabContent(
                  context,
                  children: [
                    const SousTitreText('Psaume 2'),
                    const SizedBox(height: 8),
                    const ReferenceBibliqueText('Psaume [numéro]'),
                    const SizedBox(height: 12),
                    const CorpsText('[Le texte du psaume 2 sera affiché ici]'),
                  ],
                ),
              // Lecture
              _buildTabContent(
                context,
                children: [
                  const RubriqueText('Lecture brève'),
                  const SizedBox(height: 8),
                  const ReferenceBibliqueText('1 Thessaloniciens 5, 16-18'),
                  const SizedBox(height: 12),
                  const CorpsText(
                    'Soyez toujours dans la joie, priez sans relâche, rendez grâce en toute circonstance.',
                  ),
                ],
              ),
              // Cantique de Syméon
              _buildTabContent(
                context,
                children: [
                  const SousTitreText('Cantique de Syméon'),
                  const SizedBox(height: 8),
                  const ReferenceBibliqueText('Luc 2, 29-32'),
                  const SizedBox(height: 12),
                  const CorpsText('[Le texte du cantique sera affiché ici]'),
                ],
              ),
              // Oraison
              _buildTabContent(
                context,
                children: [
                  const RubriqueText('Oraison'),
                  const SizedBox(height: 12),
                  const CorpsText(
                    '[La prière de conclusion sera affichée ici]',
                  ),
                  const SizedBox(height: 24),
                  const CorpsText(
                    'Que le Seigneur nous bénisse,\n'
                    'qu\'il nous garde de tout mal,\n'
                    'et nous conduise à la vie éternelle. Amen.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Méthode helper pour récupérer le texte de l'hymne depuis _complineData
  String _getHymnText() {
    if (_complineData != null && _complineData!.containsKey('hymn')) {
      // Accéder aux données de l'hymne
      // Ajustez selon la structure réelle de votre objet Compline
      return _complineData!['hymn']?.toString() ??
          '[Hymne en cours de chargement]';
    }
    return '[Le texte de l\'hymne sera affiché ici]';
  }

  Widget _buildTabContent(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
