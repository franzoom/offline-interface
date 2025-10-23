import 'package:flutter/material.dart';
import 'package:offline_liturgy/assets/libraries/hymns_library.dart';
import 'package:offline_liturgy/classes/hymns_class.dart';
import '../styles.dart';
import '../utils/html_helper.dart';
import '../utils/liturgy_parser.dart'; // ⭐ Import du parser réutilisable

/// Reusable widget to display and select hymns from a list
/// VERSION 2 - Using LiturgyParser for consistent formatting
class HymnSelector extends StatefulWidget {
  final String title;
  final List<String> hymnCodes;

  const HymnSelector({
    Key? key,
    required this.title,
    required this.hymnCodes,
  }) : super(key: key);

  @override
  State<HymnSelector> createState() => _HymnSelectorState();
}

class _HymnSelectorState extends State<HymnSelector> {
  String? _selectedHymnCode;
  Hymns? _selectedHymn;

  @override
  void initState() {
    super.initState();
    _initializeSelection();
  }

  @override
  void didUpdateWidget(HymnSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize if hymn codes changed
    if (oldWidget.hymnCodes != widget.hymnCodes) {
      _initializeSelection();
    }
  }

  void _initializeSelection() {
    if (widget.hymnCodes.isNotEmpty) {
      _selectedHymnCode = widget.hymnCodes.first;
      _selectedHymn = hymnsLibraryContent[_selectedHymnCode];
    } else {
      _selectedHymnCode = null;
      _selectedHymn = null;
    }
  }

  void _onHymnChanged(String? newCode) {
    if (newCode != null && newCode != _selectedHymnCode) {
      setState(() {
        _selectedHymnCode = newCode;
        _selectedHymn = hymnsLibraryContent[newCode];
      });
    }
  }

  String _formatHymnTitle(String? code) {
    if (code == null) return 'Hymne non disponible';
    final hymn = hymnsLibraryContent[code];
    return hymn?.title ?? 'Hymne introuvable: $code';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // If no hymns available
    if (widget.hymnCodes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SousTitreText(widget.title),
          const SizedBox(height: 12),
          Text(
            'Aucune hymne disponible',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        SousTitreText(widget.title),
        const SizedBox(height: 12),

        // Hymn selector dropdown (only show if multiple hymns)
        if (widget.hymnCodes.length > 1) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF374151)
                  : const Color(0xFFFED7AA).withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF4B5563)
                    : const Color(0xFFD97706).withOpacity(0.3),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedHymnCode,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFFD1D5DB)
                      : const Color(0xFF374151),
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: isDark
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFFD97706),
                ),
                items: widget.hymnCodes.map((String code) {
                  return DropdownMenuItem<String>(
                    value: code,
                    child: Text(_formatHymnTitle(code)),
                  );
                }).toList(),
                onChanged: _onHymnChanged,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Selected hymn display
        if (_selectedHymn != null) ...[
          // Hymn title (if different from widget title and not single hymn)
          if (widget.hymnCodes.length > 1) ...[
            Text(
              _selectedHymn!.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Author (if exists)
          if (_selectedHymn!.author != null &&
              _selectedHymn!.author!.isNotEmpty) ...[
            Text(
              _selectedHymn!.author!,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Hymn content using LiturgyParser
          // This will automatically handle:
          // - R/ → ℟ (red)
          // - V/ → ℣ (red)
          // - * and + (red with non-breaking spaces)
          // - Verse numbers if present (red, aligned left)
          _buildHymnContent(_selectedHymn!.content, isDark),
        ] else ...[
          Text(
            'Hymne non disponible',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
        ],
      ],
    );
  }

  /// Build hymn content using LiturgyParser
  ///
  /// The parser will:
  /// - Convert R/ to ℟ and V/ to ℣ (in red)
  /// - Color *, + in red
  /// - Add non-breaking spaces before * and +
  /// - Handle verse numbers if present (rare in hymns)
  Widget _buildHymnContent(String content, bool isDark) {
    final preparedContent = prepareLiturgicalHtml(content);

    // Try to parse with LiturgyParser first
    final paragraphes = LiturgyParser.parseHtmlContent(preparedContent);

    // If HTML parsing succeeded and found structured content
    if (paragraphes.isNotEmpty) {
      // Use full parser for structured content (with verse numbers)
      return LiturgyParser.buildFromHtml(
        htmlContent: preparedContent,
        isDark: isDark,
        onParseError: () => _buildFallbackContent(preparedContent, isDark),
      );
    } else {
      // For hymns without verse numbers, parse by stanzas
      return _buildStanzaContent(preparedContent, isDark);
    }
  }

  /// Build content for hymns organized in stanzas (no verse numbers)
  Widget _buildStanzaContent(String htmlContent, bool isDark) {
    // Use LiturgyParser's built-in method for parsing by stanzas
    return LiturgyParser.buildByStanzas(
      htmlContent: htmlContent,
      isDark: isDark,
      fontSize: 16,
      stanzaSpacing: 12,
    );
  }

  /// Fallback content builder (in case of parsing error)
  Widget _buildFallbackContent(String htmlContent, bool isDark) {
    final cleanText = LiturgyParser.cleanHtmlTags(htmlContent);
    return LiturgyParser.buildParsedText(cleanText, isDark);
  }
}
