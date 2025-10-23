import 'package:flutter/material.dart';
import 'package:offline_liturgy/assets/libraries/psalms_library.dart';
import '../styles.dart';
import '../utils/liturgy_parser.dart';

/// Widget to display a psalm with its antiphons
/// VERSION 2 - Using LiturgyParser
class PsalmDisplay extends StatelessWidget {
  final String? psalmKey;
  final String? antiphon1;
  final String? antiphon2;
  final String? antiphon3;

  const PsalmDisplay({
    Key? key,
    required this.psalmKey,
    this.antiphon1,
    this.antiphon2,
    this.antiphon3,
  }) : super(key: key);

  bool get _hasAntiphons => antiphon1 != null && antiphon1!.isNotEmpty;

  int get _antiphonCount {
    int count = 0;
    if (antiphon1 != null && antiphon1!.isNotEmpty) count++;
    if (antiphon2 != null && antiphon2!.isNotEmpty && antiphon2 != antiphon1)
      count++;
    if (antiphon3 != null &&
        antiphon3!.isNotEmpty &&
        antiphon3 != antiphon1 &&
        antiphon3 != antiphon2) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // If no psalm key provided
    if (psalmKey == null || psalmKey!.isEmpty) {
      return const CorpsText('[Psaume non disponible]');
    }

    // Get psalm from library
    final psalm = psalms[psalmKey];

    // If psalm not found
    if (psalm == null) {
      return CorpsText('[Psaume "$psalmKey" non trouvé]');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Psalm title
        SousTitreText(psalm.getTitle ?? 'Psaume'),
        const SizedBox(height: 8),

        // Psalm subtitle (if exists) - BIGGER SIZE
        if (psalm.getSubtitle != null && psalm.getSubtitle!.isNotEmpty) ...[
          Text(
            psalm.getSubtitle!,
            style: TextStyle(
              fontSize: 16, // Increased from 14
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Psalm commentary (if exists)
        if (psalm.getCommentary != null && psalm.getCommentary!.isNotEmpty) ...[
          Card(
            color: isDark
                ? const Color(0xFF374151)
                : const Color(0xFFFED7AA).withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      psalm.getCommentary!,
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
          const SizedBox(height: 16),
        ],

        // Antiphons before psalm - NO BOX
        if (_hasAntiphons) ...[
          _buildAntiphons(isDark),
          const SizedBox(height: 16),
        ],

        // Psalm content - using LiturgyParser
        _buildPsalmContent(psalm.getContent, isDark),

        // Antiphons after psalm - NO BOX
        if (_hasAntiphons) ...[
          const SizedBox(height: 16),
          _buildAntiphons(isDark),
        ],
      ],
    );
  }

  Widget _buildAntiphons(bool isDark) {
    final hasMultiple = _antiphonCount > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Antiphon 1
        if (antiphon1 != null && antiphon1!.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: hasMultiple ? 'Ant. 1 ' : 'Ant. ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFD97706),
                  ),
                ),
                // Use LiturgyParser for antiphon text
                ...LiturgyParser.parseSpecialCharacters(
                  antiphon1!,
                  isDark,
                  fontSize: 15,
                  isItalic: true,
                ),
              ],
            ),
          ),
        ],

        // Antiphon 2 (if different from antiphon 1)
        if (antiphon2 != null &&
            antiphon2!.isNotEmpty &&
            antiphon2 != antiphon1) ...[
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Ant. 2 ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFD97706),
                  ),
                ),
                // Use LiturgyParser for antiphon text
                ...LiturgyParser.parseSpecialCharacters(
                  antiphon2!,
                  isDark,
                  fontSize: 15,
                  isItalic: true,
                ),
              ],
            ),
          ),
        ],

        // Antiphon 3 (if exists and different)
        if (antiphon3 != null &&
            antiphon3!.isNotEmpty &&
            antiphon3 != antiphon1 &&
            antiphon3 != antiphon2) ...[
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Ant. 3 ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFD97706),
                  ),
                ),
                // Use LiturgyParser for antiphon text
                ...LiturgyParser.parseSpecialCharacters(
                  antiphon3!,
                  isDark,
                  fontSize: 15,
                  isItalic: true,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPsalmContent(String? content, bool isDark) {
    if (content == null || content.isEmpty) {
      return const CorpsText('[Contenu du psaume non disponible]');
    }

    // Use LiturgyParser to build the complete psalm from HTML
    return LiturgyParser.buildFromHtml(
      htmlContent: content,
      isDark: isDark,
      onParseError: () => const CorpsText('[Erreur de parsing du psaume]'),
    );
  }
}
