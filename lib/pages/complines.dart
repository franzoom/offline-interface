import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles.dart';
import '../services/calendar_service.dart';
import '../widgets/hymn_selector.dart';
import '../widgets/psalm_display.dart';
import '../widgets/canticle_display.dart';
import '../utils/liturgy_parser.dart';
import '../utils/html_helper.dart';
import 'package:offline_liturgy/offline_liturgy.dart';
import 'package:offline_liturgy/assets/libraries/psalms_library.dart';

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

  // List of available complines
  Map<String, ComplineDefinition> _availableComplines = {};
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
  void didUpdateWidget(Complines oldWidget) {
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
    final psalmCount = _getPsalmCount();
    _tabController = TabController(length: 6 + psalmCount, vsync: this);

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
        final psalmCount = _getPsalmCount();
        _tabController.dispose();
        _tabController = TabController(length: 6 + psalmCount, vsync: this);
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

  // Updated for new structure
  int _getPsalmCount() {
    if (_complineData == null) return 1;
    final mainCompline = _complineData!.values.firstOrNull;
    if (mainCompline == null) return 1;
    return mainCompline.psalmody?.length ?? 1;
  }

  Compline? get _mainCompline => _complineData?.values.firstOrNull;

  // Helper method to get psalm title from psalm key
  String _getPsalmTitle(String? psalmKey) {
    if (psalmKey == null || psalmKey.isEmpty) return 'Psaume';
    final psalm = psalms[psalmKey];
    return psalm?.getTitle ?? 'Psaume';
  }

  Widget _getReadingContent() {
    final compline = _mainCompline;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RubriqueText('Lecture brève'),
        const SizedBox(height: 8),
        // Updated for new structure
        if (compline?.reading?['ref'] != null) ...[
          ReferenceBibliqueText(compline!.reading!['ref']!),
          const SizedBox(height: 12),
        ],
        // Use LiturgyParser for reading text
        _buildReadingText(
          compline?.reading?['content'] ??
              'Soyez toujours dans la joie, priez sans relâche, rendez grâce en toute circonstance.',
          isDark,
        ),
        if (compline?.responsory != null) ...[
          const SizedBox(height: 16),
          const RubriqueText('Répons'),
          const SizedBox(height: 8),
          // Use LiturgyParser for responsory text (contains HTML and R/V/ characters)
          _buildResponsoryText(compline!.responsory!, isDark),
        ],
      ],
    );
  }

  /// Build reading text using LiturgyParser
  Widget _buildReadingText(String content, bool isDark) {
    // Prepare HTML content
    final preparedContent = prepareLiturgicalHtml(content);

    // Use LiturgyParser to build by stanzas (readings usually don't have verse numbers)
    return LiturgyParser.buildByStanzas(
      htmlContent: preparedContent,
      isDark: isDark,
      fontSize: 16,
      stanzaSpacing: 12,
    );
  }

  /// Build responsory text using LiturgyParser (handles R/, V/, and HTML)
  Widget _buildResponsoryText(String content, bool isDark) {
    // Prepare HTML content
    final preparedContent = prepareLiturgicalHtml(content);

    // Use LiturgyParser to build by stanzas
    return LiturgyParser.buildByStanzas(
      htmlContent: preparedContent,
      isDark: isDark,
      fontSize: 16,
      stanzaSpacing: 12,
    );
  }

  Widget _getCanticleContent() {
    final compline = _mainCompline;

    return CanticleDisplay(
      canticleKey: 'NT_2',
      antiphon: compline?.evangelicAntiphon,
    );
  }

  Widget _getOrationContent() {
    final compline = _mainCompline;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SousTitreText('Oraison'),
        const SizedBox(height: 12),
        // Updated for new structure
        if (compline?.oration != null && compline!.oration!.isNotEmpty) ...[
          // If multiple orations, join them with spacing
          ...compline.oration!.map((orationText) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: CorpsText(orationText.toString()),
              )),
        ] else
          const CorpsText('[Oraison en cours de chargement]'),
        const SizedBox(height: 24),
        const RubriqueText('Bénédiction finale'),
        const SizedBox(height: 12),
        const CorpsText(
          'Que le Seigneur tout-puissant nous accorde une nuit tranquille et une mort sainte.\n'
          'Amen.',
        ),
      ],
    );
  }

  Widget _getMarialHymnContent() {
    final compline = _mainCompline;

    if (compline?.marialHymnRef != null &&
        compline!.marialHymnRef!.isNotEmpty) {
      return HymnSelector(
        title: 'Hymne mariale',
        hymnCodes: compline.marialHymnRef!,
      );
    }

    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SousTitreText('Hymne mariale'),
        SizedBox(height: 12),
        CorpsText('[Aucune hymne mariale disponible]'),
      ],
    );
  }

  Widget _buildComplineSelector(BuildContext context, bool isDark) {
    if (_availableComplines.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Complies : ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF111827),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<int>(
              value: _selectedComplineIndex,
              isExpanded: true,
              underline: Container(
                height: 2,
                color:
                    isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
              ),
              dropdownColor:
                  isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
              items: _availableComplines.asMap().entries.map((entry) {
                final index = entry.key;
                final complineMap = entry.value;
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(_getComplineName(complineMap)),
                );
              }).toList(),
              onChanged: _onComplineChanged,
            ),
          ),
        ],
      ),
    );
  }

  // Build psalm tabs dynamically
  List<Widget> _buildPsalmTabs() {
    final tabs = <Widget>[];

    if (_mainCompline?.psalmody != null) {
      for (var psalmItem in _mainCompline!.psalmody!) {
        final psalmKey = psalmItem['psalm'] as String?;
        tabs.add(Tab(text: _getPsalmTitle(psalmKey)));
      }
    } else {
      // Fallback if no psalmody data
      tabs.add(const Tab(text: 'Psaume'));
    }

    return tabs;
  }

  // Build psalm content tabs dynamically
  List<Widget> _buildPsalmContents(BuildContext context) {
    final contents = <Widget>[];

    if (_mainCompline?.psalmody != null) {
      for (var psalmItem in _mainCompline!.psalmody!) {
        final psalmKey = psalmItem['psalm'] as String?;
        final antiphons = List<String>.from(psalmItem['antiphon'] ?? []);

        contents.add(
          _buildTabContent(
            context,
            children: [
              if (psalmKey != null)
                PsalmDisplay(
                  psalmKey: psalmKey,
                  antiphon1: antiphons.isNotEmpty ? antiphons[0] : null,
                  antiphon2: antiphons.length > 1 ? antiphons[1] : null,
                )
              else
                const CorpsText('[Psaume en cours de chargement]'),
            ],
          ),
        );
      }
    } else {
      // Fallback if no psalmody data
      contents.add(
        _buildTabContent(
          context,
          children: [const CorpsText('[Psaume en cours de chargement]')],
        ),
      );
    }

    return contents;
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

    final compline = _mainCompline;

    return Column(
      children: [
        // Compline selector (if multiple options)
        _buildComplineSelector(context, isDark),

        // Tab bar - Updated for new structure
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
              ..._buildPsalmTabs(),
              const Tab(text: 'Lecture'),
              const Tab(text: 'Cantique'),
              const Tab(text: 'Oraison'),
              const Tab(text: 'Hymne mariale'),
            ],
          ),
        ),
        // Tab content - Updated for new structure
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
                  // Updated for new structure
                  if (compline?.commentary != null) ...[
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
                                compline!.commentary!,
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
              // Hymne - Updated for new structure
              _buildTabContent(
                context,
                children: [
                  if (_mainCompline?.hymns != null &&
                      _mainCompline!.hymns!.isNotEmpty)
                    HymnSelector(
                      title: 'Hymne',
                      hymnCodes: _mainCompline!.hymns!.cast<String>(),
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
              // Psalms - dynamically built
              ..._buildPsalmContents(context),
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
              // Hymne mariale
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
