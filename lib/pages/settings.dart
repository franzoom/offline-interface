import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location.dart';

class LocationItem {
  final String displayName;
  final String continentId;
  final String? countryId;
  final String? dioceseId;
  final int level; // 0=continent, 1=country, 2=diocese

  LocationItem({
    required this.displayName,
    required this.continentId,
    this.countryId,
    this.dioceseId,
    required this.level,
  });

  String get uniqueId {
    if (dioceseId != null) return '$continentId-$countryId-$dioceseId';
    if (countryId != null) return '$continentId-$countryId';
    return continentId;
  }
}

class SettingsPage extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final bool useSerifFont;
  final VoidCallback onToggleFont;
  final double textScale;
  final Function(double) onTextScaleChanged;

  const SettingsPage({
    Key? key,
    required this.themeMode,
    required this.onToggleTheme,
    required this.useSerifFont,
    required this.onToggleFont,
    required this.textScale,
    required this.onTextScaleChanged,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  LocationHierarchy? _locationHierarchy;
  List<LocationItem> _allLocations = [];
  String? _selectedLocationId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadLocations();
    await _loadSavedLocation();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadLocations() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/locations.json',
      );
      final jsonData = json.decode(jsonString);
      _locationHierarchy = LocationHierarchy.fromJson(jsonData);

      // Construire la liste plate de tous les emplacements
      _buildLocationList();
    } catch (e) {
      print('Erreur lors du chargement des localisations: $e');
    }
  }

  void _buildLocationList() {
    _allLocations.clear();

    if (_locationHierarchy == null) return;

    for (var continent in _locationHierarchy!.continents) {
      // Ajouter le continent
      _allLocations.add(LocationItem(
        displayName: continent.nameFr,
        continentId: continent.id,
        level: 0,
      ));

      // Ajouter les pays du continent
      for (var country in continent.countries) {
        _allLocations.add(LocationItem(
          displayName: '  ${country.nameFr}', // Indentation avec espaces
          continentId: continent.id,
          countryId: country.id,
          level: 1,
        ));

        // Ajouter les diocèses du pays
        for (var diocese in country.dioceses) {
          _allLocations.add(LocationItem(
            displayName: '    ${diocese.nameFr}', // Double indentation
            continentId: continent.id,
            countryId: country.id,
            dioceseId: diocese.id,
            level: 2,
          ));
        }
      }
    }
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedLocationId = prefs.getString('selected_location_id');
  }

  Future<void> _saveLocation(String locationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_location_id', locationId);
  }

  String _getLocationDisplay() {
    if (_selectedLocationId == null) return 'Non sélectionné';

    final location = _allLocations.firstWhere(
      (loc) => loc.uniqueId == _selectedLocationId,
      orElse: () => LocationItem(
        displayName: 'Non sélectionné',
        continentId: '',
        level: 0,
      ),
    );

    return location.displayName
        .trim(); // Enlever les espaces d'indentation pour l'affichage
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Paramètres'),
          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paramètres',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F),
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Apparence
          Text(
            'Apparence',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F),
            ),
          ),
          const SizedBox(height: 16),

          // Carte pour le thème
          Card(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            elevation: 2,
            child: ListTile(
              leading: Icon(
                widget.themeMode == ThemeMode.light
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color:
                    isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
              ),
              title: Text(
                'Thème',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFD1D5DB)
                      : const Color(0xFF374151),
                ),
              ),
              subtitle: Text(
                widget.themeMode == ThemeMode.light
                    ? 'Mode clair'
                    : 'Mode sombre',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                ),
              ),
              trailing: Switch(
                value: widget.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  widget.onToggleTheme();
                  _saveThemePreference(value);
                },
                activeColor: const Color(0xFFFBBF24),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Carte pour la police
          Card(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            elevation: 2,
            child: ListTile(
              leading: Icon(
                widget.useSerifFont ? Icons.font_download : Icons.text_fields,
                color:
                    isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
              ),
              title: Text(
                'Police de caractères',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFD1D5DB)
                      : const Color(0xFF374151),
                ),
              ),
              subtitle: Text(
                widget.useSerifFont
                    ? 'Avec serif (EB Garamond)'
                    : 'Sans serif (système)',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                ),
              ),
              trailing: Switch(
                value: widget.useSerifFont,
                onChanged: (value) {
                  widget.onToggleFont();
                  _saveFontPreference(value);
                },
                activeColor: const Color(0xFFFBBF24),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Carte pour la taille du texte
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
                        Icons.format_size,
                        color: isDark
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Taille du texte',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark
                              ? const Color(0xFFD1D5DB)
                              : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: widget.textScale,
                          min: 0.8,
                          max: 1.5,
                          divisions: 7,
                          label: '${(widget.textScale * 100).round()}%',
                          activeColor: isDark
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFFD97706),
                          onChanged: (value) {
                            widget.onTextScaleChanged(value);
                            _saveTextScale(value);
                          },
                        ),
                      ),
                      Text(
                        'A',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      '${(widget.textScale * 100).round()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Section Localisation
          Text(
            'Localisation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sélection du lieu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFFD1D5DB)
                          : const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lieu actuel : ${_getLocationDisplay()}',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Liste déroulante unique avec tous les emplacements
                  DropdownButtonFormField<String>(
                    key: ValueKey(_selectedLocationId),
                    initialValue: _selectedLocationId,
                    decoration: InputDecoration(
                      labelText: 'Emplacement',
                      labelStyle: TextStyle(
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    dropdownColor:
                        isDark ? const Color(0xFF1F2937) : Colors.white,
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFD1D5DB)
                          : const Color(0xFF374151),
                    ),
                    isExpanded: true,
                    items: _allLocations.map((location) {
                      return DropdownMenuItem<String>(
                        value: location.uniqueId,
                        child: Text(
                          location.displayName,
                          style: TextStyle(
                            fontWeight: location.level == 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: location.level == 0
                                ? (isDark
                                    ? const Color(0xFFFBBF24)
                                    : const Color(0xFFD97706))
                                : (isDark
                                    ? const Color(0xFFD1D5DB)
                                    : const Color(0xFF374151)),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value != null) {
                        setState(() {
                          _selectedLocationId = value;
                        });
                        await _saveLocation(value);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Localisation mise à jour'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Section À propos
          Text(
            'À propos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Liturgie des Heures',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFFD1D5DB)
                          : const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Application pour suivre la Liturgie des Heures selon le rite romain.',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveThemePreference(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }

  Future<void> _saveFontPreference(bool useSerif) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_serif_font', useSerif);
  }

  Future<void> _saveTextScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('text_scale', scale);
  }
}
