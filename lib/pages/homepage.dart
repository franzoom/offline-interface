import 'package:flutter/material.dart';
import 'informations.dart';
import 'offices.dart';
import 'settings.dart';
import 'complines.dart';
import '../utils/date_utils.dart' as utils;
import '../services/calendar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final bool useSerifFont;
  final VoidCallback onToggleFont;
  final double textScale;
  final Function(double) onTextScaleChanged;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const HomePage({
    Key? key,
    required this.themeMode,
    required this.onToggleTheme,
    required this.useSerifFont,
    required this.onToggleFont,
    required this.textScale,
    required this.onTextScaleChanged,
    required this.selectedDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentPage = 'informations';
  bool _isLoadingCalendar = false;

  final List<MenuItem> _menuItems = [
    MenuItem(
      id: 'informations',
      label: 'Informations',
      icon: Icons.info_outline,
    ),
    MenuItem(id: 'laudes', label: 'Laudes', icon: Icons.wb_sunny_outlined),
    MenuItem(
      id: 'lectures',
      label: 'Office des Lectures',
      icon: Icons.menu_book_outlined,
    ),
    MenuItem(
      id: 'milieu',
      label: 'Milieu du Jour',
      icon: Icons.wb_twilight_outlined,
    ),
    MenuItem(id: 'vepres', label: 'Vêpres', icon: Icons.brightness_3_outlined),
    MenuItem(id: 'complies', label: 'Complies', icon: Icons.bedtime_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _ensureCalendarLoaded();
  }

  /// S'assure que le calendrier est chargé pour la date sélectionnée
  Future<void> _ensureCalendarLoaded() async {
    final prefs = await SharedPreferences.getInstance();
    final location = prefs.getString('selected_location_id');

    if (location == null) {
      print('Aucune localisation sélectionnée');
      return;
    }

    final year = widget.selectedDate.year;

    if (!CalendarService().isYearLoaded(year)) {
      setState(() {
        _isLoadingCalendar = true;
      });

      await CalendarService().ensureYearLoaded(year, location);

      if (mounted) {
        setState(() {
          _isLoadingCalendar = false;
        });
      }
    }
  }

  void _changePage(String pageId) {
    setState(() {
      _currentPage = pageId;
    });
  }

  String _getCurrentPageLabel() {
    return _menuItems.firstWhere((item) => item.id == _currentPage).label;
  }

  Widget _getPageContent() {
    switch (_currentPage) {
      case 'informations':
        return InformationsPage(selectedDate: widget.selectedDate);
      case 'laudes':
        return OfficePage(title: 'Laudes', selectedDate: widget.selectedDate);
      case 'lectures':
        return OfficePage(
            title: 'Office des Lectures', selectedDate: widget.selectedDate);
      case 'milieu':
        return OfficePage(
            title: 'Milieu du Jour', selectedDate: widget.selectedDate);
      case 'vepres':
        return OfficePage(title: 'Vêpres', selectedDate: widget.selectedDate);
      case 'complies':
        return Complines(title: 'Complies', selectedDate: widget.selectedDate);
      default:
        return InformationsPage(selectedDate: widget.selectedDate);
    }
  }

  // Fonction pour afficher le sélecteur de date
  Future<void> _selectDate(BuildContext context) async {
    final isDark = widget.themeMode == ThemeMode.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: const Color(0xFFFBBF24),
                    onPrimary: const Color(0xFF111827),
                    surface: const Color(0xFF1F2937),
                    onSurface: const Color(0xFFD1D5DB),
                    background: const Color(0xFF111827),
                    onBackground: const Color(0xFFD1D5DB),
                  )
                : ColorScheme.light(
                    primary: const Color(0xFFD97706),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: const Color(0xFF374151),
                    background: const Color(0xFFFFFBEB),
                    onBackground: const Color(0xFF374151),
                  ),
            dialogBackgroundColor:
                isDark ? const Color(0xFF1F2937) : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != widget.selectedDate) {
      widget.onDateChanged(picked);

      // Vérifier si l'année du calendrier doit être chargée
      final prefs = await SharedPreferences.getInstance();
      final location = prefs.getString('selected_location_id');

      if (location != null && picked.year != widget.selectedDate.year) {
        setState(() {
          _isLoadingCalendar = true;
        });

        await CalendarService().ensureYearLoaded(picked.year, location);

        if (mounted) {
          setState(() {
            _isLoadingCalendar = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        // Bouton de menu à gauche
        leading: PopupMenuButton<String>(
          icon: Icon(
            Icons.menu_book,
            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F),
          ),
          tooltip: 'Choisir un office',
          onSelected: _changePage,
          itemBuilder: (BuildContext context) {
            return _menuItems.map((MenuItem item) {
              return PopupMenuItem<String>(
                value: item.id,
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: _currentPage == item.id
                          ? (isDark
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFFD97706))
                          : (isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontWeight: _currentPage == item.id
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: _currentPage == item.id
                            ? (isDark
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFFD97706))
                            : null,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
        ),
        // Titre remplacé par la date formatée
        title: Text(
          utils.DateUtils.formatDateFrench(widget.selectedDate),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F),
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        actions: [
          // Bouton Calendrier (NOUVEAU)
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F),
            ),
            tooltip: 'Sélectionner une date',
            onPressed: () => _selectDate(context),
          ),
          // Bouton Paramètres
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F),
            ),
            tooltip: 'Paramètres',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    themeMode: widget.themeMode,
                    onToggleTheme: widget.onToggleTheme,
                    useSerifFont: widget.useSerifFont,
                    onToggleFont: widget.onToggleFont,
                    textScale: widget.textScale,
                    onTextScaleChanged: widget.onTextScaleChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicateur de la page actuelle
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF374151)
                  : const Color(0xFFFED7AA).withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? const Color(0xFF4B5563)
                      : const Color(0xFFFED7AA),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              _getCurrentPageLabel(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F),
              ),
            ),
          ),
          // Contenu de la page
          Expanded(
            child: _isLoadingCalendar
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: isDark
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chargement du calendrier...',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  )
                : _getPageContent(),
          ),
        ],
      ),
    );
  }
}

class MenuItem {
  final String id;
  final String label;
  final IconData icon;

  MenuItem({required this.id, required this.label, required this.icon});
}
