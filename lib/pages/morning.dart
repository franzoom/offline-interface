import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles.dart';
import '../services/calendar_service.dart';
import '../widgets/hymn_selector.dart';
import '../widgets/psalm_display.dart';
import 'package:offline_liturgy/offline_liturgy.dart';

class Morning extends StatefulWidget {
  final String title;
  final DateTime selectedDate;

  const Morning({
    Key? key,
    required this.title,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<Morning> createState() => _CompliesState();
}

class _CompliesState extends State<Morning>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // List of available complines
  List<Map<String, ComplineDefinition>> _availableComplines = [];
  int _selectedComplineIndex = 0;

  // Current compiled compline data
  Map<String, Compline>? _complineData;

  String _location = 'lyon'; // Default location
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(Morning oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data if date changed
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

    // Initialize TabController after having data
    final hasPsalm2 = _hasTwoPsalms();
    _tabController = TabController(length: hasPsalm2 ? 8 : 7, vsync: this);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    _location = prefs.getString('keySelectedLocation') ??
        prefs.getString('keyPrefRegion') ??
        'lyon';
    print('Location loaded: $_location');
  }

  Future<void> _loadComplinesData() async {
    final calendar = CalendarService().calendar;

    if (calendar.calendarData.isEmpty) {
      print('Calendar not available or empty');
      return;
    }

    try {
      print('Loading Complines for ${widget.selectedDate} and $_location');

      // Step 1: Get list of available complines
      _availableComplines = complineDefinitionResolution(
        calendar,
        widget.selectedDate,
      );

      print('Available complines: ${_availableComplines.length}');

      // Reset selection if out of bounds
      if (_selectedComplineIndex >= _availableComplines.length) {
        _selectedComplineIndex = 0;
      }

      // Step 2: Compile text for selected compline
      _compileCurrentCompline();
    } catch (e, stackTrace) {
      print('Error loading Complines: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _compileCurrentCompline() {
    if (_availableComplines.isEmpty) return;

    try {
      _complineData =
          complineTextCompilation(_availableComplines[_selectedComplineIndex]);
      print('Compline texts compiled: ${_complineData?.keys}');
    } catch (e, stackTrace) {
      print('Error compiling compline: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _onComplineChanged(int? newIndex) {
    if (newIndex != null && newIndex != _selectedComplineIndex) {
      setState(() {
        _selectedComplineIndex = newIndex;
        _compileCurrentCompline();

        // Reinitialize TabController if psalm count changed
        final hasPsalm2 = _hasTwoPsalms();
        _tabController.dispose();
        _tabController = TabController(length: hasPsalm2 ? 8 : 7, vsync: this);
      });
    }
  }

  String _getComplineName(Map<String, ComplineDefinition> complineMap) {
    final entry = complineMap.entries.first;
    final definition = entry.value;

    // Format readable name
    if (definition.celebrationType == 'SolemnityEve') {
      return 'Veille de ${_formatKey(entry.key)}';
    } else if (definition.celebrationType == 'Solemnity') {
      return 'Solennité de ${_formatKey(entry.key)}';
    } else if (definition.celebrationType == 'Sunday') {
      return 'Complies du dimanche';
    } else {
      return 'Complies du jour';
    }
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  bool _hasTwoPsalms() {
    if (_complineData == null) return false;
    final mainCompline = _complineData!.values.firstOrNull;
    if (mainCompline == null) return false;
    return mainCompline.complinePsalm2 != null &&
        mainCompline.complinePsalm2!.isNotEmpty;
  }

  Compline? get _mainCompline => _complineData?.values.firstOrNull;

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
      ],
    );
  }

  Widget _getMarialHymnContent() {
    final compline = _mainCompline;

    if (compline?.marialHymnRef == null || compline!.marialHymnRef!.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SousTitreText('Hymne à Marie'),
          SizedBox(height: 12),
          CorpsText('[Aucune hymne mariale disponible]'),
        ],
      );
    }

    return HymnSelector(
      title: 'Hymne à Marie',
      hymnCodes: compline.marialHymnRef!.cast<String>(),
    );
  }

  Widget _buildComplineSelector(BuildContext context, bool isDark) {
    if (_availableComplines.length <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF374151)
            : const Color(0xFFFED7AA).withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? const Color(0xFF4B5563)
                : const Color(0xFFD97706).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.church,
            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedComplineIndex,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFD1D5DB)
                      : const Color(0xFF374151),
                  fontSize: 14,
                ),
                items: List.generate(
                  _availableComplines.length,
                  (index) => DropdownMenuItem(
                    value: index,
                    child: Text(_getComplineName(_availableComplines[index])),
                  ),
                ),
                onChanged: _onComplineChanged,
              ),
            ),
          ),
        ],
      ),
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
        // Compline selector (if multiple options)
        _buildComplineSelector(context, isDark),

        // Tab bar
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
              const Tab(text: 'Hymne mariale'),
            ],
          ),
        ),
        // Tab content
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
                  if (_mainCompline?.complineHymns != null &&
                      _mainCompline!.complineHymns!.isNotEmpty)
                    HymnSelector(
                      title: 'Hymne',
                      hymnCodes: _mainCompline!.complineHymns!.cast<String>(),
                    )
                  else
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SousTitreText('Hymne'),
                        SizedBox(height: 12),
                        CorpsText('[Aucune hymne disponible]'),
                      ],
                    ),
                ],
              ),
              // Psaume 1
              _buildTabContent(
                context,
                children: [
                  if (_mainCompline != null)
                    PsalmDisplay(
                      psalmKey: _mainCompline!.complinePsalm1,
                      antiphon1: _mainCompline!.complinePsalm1Antiphon,
                      antiphon2: _mainCompline!.complinePsalm1Antiphon2,
                    )
                  else
                    const CorpsText('[Psaume en cours de chargement]'),
                ],
              ),
              // Psaume 2 (conditional)
              if (hasPsalm2)
                _buildTabContent(
                  context,
                  children: [
                    if (_mainCompline != null)
                      PsalmDisplay(
                        psalmKey: _mainCompline!.complinePsalm2,
                        antiphon1: _mainCompline!.complinePsalm2Antiphon,
                        antiphon2: _mainCompline!.complinePsalm2Antiphon2,
                      )
                    else
                      const CorpsText('[Psaume en cours de chargement]'),
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
              // Hymne mariale (new tab)
              _buildTabContent(
                context,
                children: [_getMarialHymnContent()],
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
