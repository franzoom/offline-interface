import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles.dart';
import '../services/calendar_service.dart';
import 'package:offline_liturgy/offline_liturgy.dart';

class Complines extends StatefulWidget {
  final String title;
  final DateTime selectedDate;

  const Complines({
    Key? key,
    required this.title,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<Complines> createState() => _CompliesState();
}

class _CompliesState extends State<Complines>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, Compline>? _complineData;
  String _location = 'europe-france'; // Par défaut France
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(Complines oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recharger les données si la date a changé
    if (oldWidget.selectedDate != widget.selectedDate) {
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    await _loadLocation();
    await _loadComplinesData();

    // Initialiser le TabController après avoir les données
    final hasPsalm2 = _hasTwoPsalms();
    _tabController = TabController(length: hasPsalm2 ? 7 : 6, vsync: this);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    _location = prefs.getString('selected_location_id') ?? 'europe-france';

    if (_location == 'europe-france') {
      print(
          'Aucune localisation sélectionnée, utilisation de "europe-france" par défaut');
    }
  }

  Future<void> _loadComplinesData() async {
    final calendar = CalendarService().calendar;

    if (calendar.calendarData.isEmpty) {
      print('Calendar non disponible ou vide');
      return;
    }

    try {
      print(
          'Chargement des Complies pour ${widget.selectedDate} et $_location');

      // Étape 1 : Résolution de la définition
      Map<String, ComplineDefinition> complineDefinitions =
          complineDefinitionResolution(
        calendar,
        widget.selectedDate,
        _location,
      );

      print('ComplineDefinitions obtenues : ${complineDefinitions.keys}');

      // Étape 2 : Compilation des textes
      _complineData = complineTextCompilation(complineDefinitions);

      print('Compline textes compilés : ${_complineData?.keys}');
    } catch (e, stackTrace) {
      print('Erreur lors du chargement des Complies : $e');
      print('Stack trace: $stackTrace');
    }
  }

  bool _hasTwoPsalms() {
    if (_complineData == null) return false;

    final mainCompline = _complineData!['compline'];
    if (mainCompline == null) return false;

    // Vérifier si le psaume 2 existe
    return mainCompline.complinePsalm2 != null &&
        mainCompline.complinePsalm2!.isNotEmpty;
  }

  Compline? get _mainCompline => _complineData?['compline'];

  String _getHymnText() {
    if (_mainCompline?.complineHymns != null &&
        _mainCompline!.complineHymns!.isNotEmpty) {
      return _mainCompline!.complineHymns!.join('\n\n');
    }
    return '[Le texte de l\'hymne sera affiché ici]';
  }

  String _getPsalm1Text() {
    final compline = _mainCompline;
    if (compline == null) return '[Psaume en cours de chargement]';

    final buffer = StringBuffer();

    // Antienne
    if (compline.complinePsalm1Antiphon != null) {
      buffer.writeln('Antienne : ${compline.complinePsalm1Antiphon}');
      buffer.writeln();
    }

    // Psaume
    if (compline.complinePsalm1 != null) {
      buffer.writeln(compline.complinePsalm1);
    } else {
      buffer.writeln('[Le texte du psaume sera affiché ici]');
    }

    // Antienne de fin (si différente)
    if (compline.complinePsalm1Antiphon2 != null &&
        compline.complinePsalm1Antiphon2 != compline.complinePsalm1Antiphon) {
      buffer.writeln();
      buffer.writeln('Antienne : ${compline.complinePsalm1Antiphon2}');
    }

    return buffer.toString();
  }

  String _getPsalm2Text() {
    final compline = _mainCompline;
    if (compline == null) return '[Psaume en cours de chargement]';

    final buffer = StringBuffer();

    // Antienne
    if (compline.complinePsalm2Antiphon != null) {
      buffer.writeln('Antienne : ${compline.complinePsalm2Antiphon}');
      buffer.writeln();
    }

    // Psaume
    if (compline.complinePsalm2 != null) {
      buffer.writeln(compline.complinePsalm2);
    } else {
      buffer.writeln('[Le texte du psaume 2 sera affiché ici]');
    }

    // Antienne de fin (si différente)
    if (compline.complinePsalm2Antiphon2 != null &&
        compline.complinePsalm2Antiphon2 != compline.complinePsalm2Antiphon) {
      buffer.writeln();
      buffer.writeln('Antienne : ${compline.complinePsalm2Antiphon2}');
    }

    return buffer.toString();
  }

  Widget _getReadingContent() {
    final compline = _mainCompline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RubriqueText('Lecture brève'),
        const SizedBox(height: 8),
        if (compline?.complineReadingRef != null) ...[
          ReferenceBibliqueText(compline!.complineReadingRef!),
          const SizedBox(height: 12),
        ],
        CorpsText(compline?.complineReading ??
            'Soyez toujours dans la joie, priez sans relâche, rendez grâce en toute circonstance.'),
        if (compline?.complineResponsory != null) ...[
          const SizedBox(height: 16),
          const RubriqueText('Répons'),
          const SizedBox(height: 8),
          CorpsText(compline!.complineResponsory!),
        ],
      ],
    );
  }

  Widget _getCanticleContent() {
    final compline = _mainCompline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SousTitreText('Cantique de Syméon'),
        const SizedBox(height: 8),
        const ReferenceBibliqueText('Luc 2, 29-32'),
        const SizedBox(height: 12),
        if (compline?.complineEvangelicAntiphon != null) ...[
          const RubriqueText('Antienne'),
          const SizedBox(height: 8),
          CorpsText(compline!.complineEvangelicAntiphon!),
          const SizedBox(height: 12),
        ],
        const CorpsText(
          'Maintenant, ô Maître souverain, *\n'
          'tu peux laisser ton serviteur s\'en aller\n'
          'en paix, selon ta parole.\n\n'
          'Car mes yeux ont vu le salut *\n'
          'que tu préparais à la face des peuples :\n\n'
          'lumière qui se révèle aux nations *\n'
          'et donne gloire à ton peuple Israël.\n\n'
          'Gloire au Père, et au Fils, et au Saint-Esprit,\n'
          'au Dieu qui est, qui était, et qui vient,\n'
          'pour les siècles des siècles. Amen.',
        ),
      ],
    );
  }

  Widget _getOrationContent() {
    final compline = _mainCompline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RubriqueText('Oraison'),
        const SizedBox(height: 12),
        if (compline?.complineOration != null &&
            compline!.complineOration!.isNotEmpty) ...[
          CorpsText(compline.complineOration!.join('\n\n')),
          const SizedBox(height: 24),
        ] else ...[
          const CorpsText('[La prière de conclusion sera affichée ici]'),
          const SizedBox(height: 24),
        ],
        const RubriqueText('Bénédiction'),
        const SizedBox(height: 8),
        const CorpsText(
          'Que le Seigneur nous bénisse,\n'
          'qu\'il nous garde de tout mal,\n'
          'et nous conduise à la vie éternelle. Amen.',
        ),
        if (compline?.marialHymnRef != null &&
            compline!.marialHymnRef!.isNotEmpty) ...[
          const SizedBox(height: 24),
          const RubriqueText('Hymne à Marie'),
          const SizedBox(height: 8),
          CorpsText(compline.marialHymnRef!.join('\n')),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final celebrations =
        CalendarService().getSortedItemsForDay(widget.selectedDate);

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement des Complies...',
              style: TextStyle(
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    final hasPsalm2 = _hasTwoPsalms();
    final compline = _mainCompline;

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
                  if (celebrations.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ReferenceBibliqueText(celebrations.first.value),
                  ],
                  if (compline?.celebrationType != null) ...[
                    const SizedBox(height: 8),
                    RubriqueText(compline!.celebrationType!),
                  ],
                  if (compline?.complineCommentary != null) ...[
                    const SizedBox(height: 12),
                    Card(
                      color: isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFFED7AA).withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: isDark
                                  ? const Color(0xFFFBBF24)
                                  : const Color(0xFFD97706),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                compline!.complineCommentary!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? const Color(0xFFD1D5DB)
                                      : const Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                  const SizedBox(height: 24),
                  const RubriqueText('Examen de conscience'),
                  const SizedBox(height: 12),
                  const CorpsText(
                    'Frères, bien-aimés, à la fin de cette journée,\n'
                    'reconnaissons-nous pécheurs et demandons pardon à Dieu.',
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
                  const SizedBox(height: 12),
                  CorpsText(_getPsalm1Text()),
                ],
              ),
              // Psaume 2 (conditionnel)
              if (hasPsalm2)
                _buildTabContent(
                  context,
                  children: [
                    const SousTitreText('Psaume 2'),
                    const SizedBox(height: 12),
                    CorpsText(_getPsalm2Text()),
                  ],
                ),
              // Lecture
              _buildTabContent(
                context,
                children: [_getReadingContent()],
              ),
              // Cantique de Syméon
              _buildTabContent(
                context,
                children: [_getCanticleContent()],
              ),
              // Oraison
              _buildTabContent(
                context,
                children: [_getOrationContent()],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
