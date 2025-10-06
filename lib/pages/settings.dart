import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location.dart';

class SettingsPage extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final bool useSerifFont;
  final VoidCallback onToggleFont;

  const SettingsPage({
    Key? key,
    required this.themeMode,
    required this.onToggleTheme,
    required this.useSerifFont,
    required this.onToggleFont,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  LocationHierarchy? _locationHierarchy;
  String? _selectedContinent;
  String? _selectedCountry;
  String? _selectedDiocese;
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
        'packages/offline_liturgy/assets/locations.json',
      );
      final jsonData = json.decode(jsonString);
      _locationHierarchy = LocationHierarchy.fromJson(jsonData);
    } catch (e) {
      print('Erreur lors du chargement des localisations: $e');
    }
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedContinent = prefs.getString('selected_continent');
      _selectedCountry = prefs.getString('selected_country');
      _selectedDiocese = prefs.getString('selected_diocese');
    });
  }

  Future<void> _saveLocation() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedContinent != null) {
      await prefs.setString('selected_continent', _selectedContinent!);
    }
    if (_selectedCountry != null) {
      await prefs.setString('selected_country', _selectedCountry!);
    }
    if (_selectedDiocese != null) {
      await prefs.setString('selected_diocese', _selectedDiocese!);
    }
  }

  List<Country> _getCountriesForContinent(String continentId) {
    final continent = _locationHierarchy?.continents.firstWhere(
      (c) => c.id == continentId,
    );
    return continent?.countries ?? [];
  }

  List<Diocese> _getDiocesesForCountry(String continentId, String countryId) {
    final countries = _getCountriesForContinent(continentId);
    final country = countries.firstWhere((c) => c.id == countryId);
    return country.dioceses;
  }

  String _getLocationDisplay() {
    if (_selectedDiocese != null &&
        _selectedCountry != null &&
        _selectedContinent != null) {
      final continent = _locationHierarchy?.continents.firstWhere(
        (c) => c.id == _selectedContinent,
      );
      final country = continent?.countries.firstWhere(
        (c) => c.id == _selectedCountry,
      );
      final diocese = country?.dioceses.firstWhere(
        (d) => d.id == _selectedDiocese,
      );

      if (diocese != null) {
        return '${diocese.nameFr}, ${country?.nameFr}, ${continent?.nameFr}';
      }
    }

    if (_selectedCountry != null && _selectedContinent != null) {
      final continent = _locationHierarchy?.continents.firstWhere(
        (c) => c.id == _selectedContinent,
      );
      final country = continent?.countries.firstWhere(
        (c) => c.id == _selectedCountry,
      );

      if (country != null) {
        return '${country.nameFr}, ${continent?.nameFr}';
      }
    }

    if (_selectedContinent != null) {
      final continent = _locationHierarchy?.continents.firstWhere(
        (c) => c.id == _selectedContinent,
      );
      return continent?.nameFr ?? 'Non sélectionné';
    }

    return 'Non sélectionné';
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
                color: isDark
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFFD97706),
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
                color: isDark
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFFD97706),
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
                    ? 'Avec serif (Georgia)'
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

                  // Continent
                  DropdownButtonFormField<String>(
                    key: ValueKey(_selectedContinent),
                    initialValue: _selectedContinent,
                    decoration: InputDecoration(
                      labelText: 'Continent',
                      labelStyle: TextStyle(
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    dropdownColor: isDark
                        ? const Color(0xFF1F2937)
                        : Colors.white,
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFD1D5DB)
                          : const Color(0xFF374151),
                    ),
                    items: _locationHierarchy?.continents.map((continent) {
                      return DropdownMenuItem<String>(
                        value: continent.id,
                        child: Text(continent.nameFr),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedContinent = value;
                        _selectedCountry = null;
                        _selectedDiocese = null;
                      });
                      _saveLocation();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Pays
                  if (_selectedContinent != null &&
                      _getCountriesForContinent(_selectedContinent!).isNotEmpty)
                    DropdownButtonFormField<String>(
                      key: ValueKey(_selectedCountry),
                      initialValue: _selectedCountry,
                      decoration: InputDecoration(
                        labelText: 'Pays',
                        labelStyle: TextStyle(
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      dropdownColor: isDark
                          ? const Color(0xFF1F2937)
                          : Colors.white,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFD1D5DB)
                            : const Color(0xFF374151),
                      ),
                      items: _getCountriesForContinent(_selectedContinent!).map(
                        (country) {
                          return DropdownMenuItem<String>(
                            value: country.id,
                            child: Text(country.nameFr),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value;
                          _selectedDiocese = null;
                        });
                        _saveLocation();
                      },
                    ),
                  if (_selectedContinent != null &&
                      _selectedCountry != null &&
                      _getCountriesForContinent(_selectedContinent!).isNotEmpty)
                    const SizedBox(height: 16),

                  // Diocèse
                  if (_selectedContinent != null &&
                      _selectedCountry != null &&
                      _getDiocesesForCountry(
                        _selectedContinent!,
                        _selectedCountry!,
                      ).isNotEmpty)
                    DropdownButtonFormField<String>(
                      key: ValueKey(_selectedDiocese),
                      initialValue: _selectedDiocese,
                      decoration: InputDecoration(
                        labelText: 'Diocèse',
                        labelStyle: TextStyle(
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      dropdownColor: isDark
                          ? const Color(0xFF1F2937)
                          : Colors.white,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFD1D5DB)
                            : const Color(0xFF374151),
                      ),
                      items:
                          _getDiocesesForCountry(
                            _selectedContinent!,
                            _selectedCountry!,
                          ).map((diocese) {
                            return DropdownMenuItem<String>(
                              value: diocese.id,
                              child: Text(diocese.nameFr),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDiocese = value;
                        });
                        _saveLocation();
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
}
