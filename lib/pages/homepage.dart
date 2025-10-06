import 'package:flutter/material.dart';
import 'informations.dart';
import 'offices.dart';

class HomePage extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final bool useSerifFont;
  final VoidCallback onToggleFont;

  const HomePage({
    Key? key,
    required this.themeMode,
    required this.onToggleTheme,
    required this.useSerifFont,
    required this.onToggleFont,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentPage = 'informations';

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
        return const InformationsPage();
      case 'laudes':
        return const OfficePage(title: 'Laudes');
      case 'lectures':
        return const OfficePage(title: 'Office des Lectures');
      case 'milieu':
        return const OfficePage(title: 'Milieu du Jour');
      case 'vepres':
        return const OfficePage(title: 'Vêpres');
      case 'complies':
        return const OfficePage(title: 'Complies');
      default:
        return const InformationsPage();
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
        title: Text(
          'Liturgie des Heures',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F),
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        actions: [
          // Icône changement de police
          IconButton(
            icon: Icon(
              widget.useSerifFont ? Icons.font_download : Icons.text_fields,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F),
            ),
            tooltip: widget.useSerifFont
                ? 'Police sans serif'
                : 'Police avec serif',
            onPressed: widget.onToggleFont,
          ),
          // Icône mode nuit/jour
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F),
            ),
            tooltip: widget.themeMode == ThemeMode.light
                ? 'Mode sombre'
                : 'Mode clair',
            onPressed: widget.onToggleTheme,
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
                  : const Color(0xFFFED7AA).withOpacity(0.3),
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
                color: isDark
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFF78350F),
              ),
            ),
          ),
          // Contenu de la page
          Expanded(child: _getPageContent()),
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
