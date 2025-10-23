import 'package:flutter/material.dart';
import 'package:offline_liturgy/assets/libraries/psalms_library.dart';
import '../styles.dart';
import '../utils/liturgy_parser.dart';

/// Widget to display a Canticle with its antiphon
/// Similar to PsalmDisplay but for NT or AT canticles
class CanticleDisplay extends StatelessWidget {
  final String? canticleKey;
  final String? antiphon;

  const CanticleDisplay({
    Key? key,
    required this.canticleKey,
    this.antiphon,
  }) : super(key: key);

  bool get _hasAntiphon => antiphon != null && antiphon!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // If no canticle key provided
    if (canticleKey == null || canticleKey!.isEmpty) {
      return const CorpsText('[Cantique non disponible]');
    }

    // Get canticle from library (same library as psalms)
    final canticle = psalms[canticleKey];

    // If canticle not found
    if (canticle == null) {
      return CorpsText('[Cantique "$canticleKey" non trouvé]');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Canticle title
        SousTitreText(canticle.getTitle ?? 'Cantique'),
        const SizedBox(height: 8),

        // Canticle subtitle (if exists) - biblical reference
        if (canticle.getSubtitle != null &&
            canticle.getSubtitle!.isNotEmpty) ...[
          ReferenceBibliqueText(canticle.getSubtitle!),
          const SizedBox(height: 12),
        ],

        // Canticle commentary (if exists)
        if (canticle.getCommentary != null &&
            canticle.getCommentary!.isNotEmpty) ...[
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
                      canticle.getCommentary!,
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

        // Antiphon before canticle
        if (_hasAntiphon) ...[
          _buildAntiphon(isDark),
          const SizedBox(height: 16),
        ],

        // Canticle content - using LiturgyParser
        _buildCanticleContent(canticle.getContent, isDark),

        // Antiphon after canticle
        if (_hasAntiphon) ...[
          const SizedBox(height: 16),
          _buildAntiphon(isDark),
        ],
      ],
    );
  }

  Widget _buildAntiphon(bool isDark) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Ant. ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
            ),
          ),
          // Use LiturgyParser for antiphon text
          ...LiturgyParser.parseSpecialCharacters(
            antiphon!,
            isDark,
            fontSize: 15,
            isItalic: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCanticleContent(String? content, bool isDark) {
    if (content == null || content.isEmpty) {
      return const CorpsText('[Contenu du cantique non disponible]');
    }

    // Use LiturgyParser to build the complete canticle from HTML
    return LiturgyParser.buildFromHtml(
      htmlContent: content,
      isDark: isDark,
      onParseError: () => const CorpsText('[Erreur de parsing du cantique]'),
    );
  }
}
