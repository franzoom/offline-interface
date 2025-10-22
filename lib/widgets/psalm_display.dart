import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:offline_liturgy/assets/libraries/psalms_library.dart';
import '../styles.dart';
import '../utils/html_helper.dart';

/// Represents a verse with its number and text lines
class _Verset {
  final int numero;
  final List<String> lignes;

  _Verset({
    required this.numero,
    required this.lignes,
  });
}

/// Represents a paragraph containing one or more verses
class _Paragraphe {
  final List<_Verset> versets;

  _Paragraphe({required this.versets});
}

/// Widget to display a psalm with its antiphons
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

        // Psalm content with custom rendering
        _buildPsalmContent(psalm.getContent, isDark),

        // Antiphons after psalm - NO BOX
        if (_hasAntiphons) ...[
          const SizedBox(height: 16),
          _buildAntiphons(isDark),
        ],
      ],
    );
  }

  /// Parse text to handle R/, V/, *, + with proper formatting and non-breaking spaces
  List<TextSpan> _parseSpecialCharacters(String text, bool isDark,
      {double fontSize = 16, bool isItalic = false}) {
    // Replace R/ with ℟ and V/ with ℣
    text = text.replaceAll('R/', '℟').replaceAll('V/', '℣');

    // Replace regular spaces before * or + with non-breaking spaces to prevent orphan characters
    text = text.replaceAll(' *', '\u00A0*');
    text = text.replaceAll(' +', '\u00A0+');

    final spans = <TextSpan>[];
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char == '+' || char == '*' || char == '℟' || char == '℣') {
        // Add accumulated text in normal color
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(
            text: buffer.toString(),
            style: TextStyle(
              fontSize: fontSize,
              height: 1.8,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
            ),
          ));
          buffer.clear();
        }

        // Add the special character in red
        spans.add(TextSpan(
          text: char,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.8,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ));
      } else {
        buffer.write(char);
      }
    }

    // Add the remaining text
    if (buffer.isNotEmpty) {
      spans.add(TextSpan(
        text: buffer.toString(),
        style: TextStyle(
          fontSize: fontSize,
          height: 1.8,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
        ),
      ));
    }

    return spans;
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
                ..._parseSpecialCharacters(antiphon1!, isDark,
                    fontSize: 15, isItalic: true),
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
                ..._parseSpecialCharacters(antiphon2!, isDark,
                    fontSize: 15, isItalic: true),
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
                ..._parseSpecialCharacters(antiphon3!, isDark,
                    fontSize: 15, isItalic: true),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Parse HTML content to extract verses and paragraphs
  List<_Paragraphe> _parseHtmlContent(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final paragraphes = <_Paragraphe>[];

    // Get all <p> elements (one <p> = one paragraph)
    final pElements = document.querySelectorAll('p');

    for (var pElement in pElements) {
      final versets = _parseParagraphe(pElement);
      if (versets.isNotEmpty) {
        paragraphes.add(_Paragraphe(versets: versets));
      }
    }

    return paragraphes;
  }

  /// Parse a <p> element and extract all verses it contains
  List<_Verset> _parseParagraphe(dom.Element pElement) {
    final versets = <_Verset>[];
    int? currentVersetNumero;
    List<String> currentLignes = [];

    void finalizeVerset() {
      if (currentVersetNumero != null && currentLignes.isNotEmpty) {
        versets.add(_Verset(
          numero: currentVersetNumero!,
          lignes: List.from(currentLignes),
        ));
        currentLignes.clear();
      }
    }

    String currentLigne = '';

    for (var node in pElement.nodes) {
      if (node is dom.Element) {
        // If it's a verse number (can be <sup>, <small>, or class="verse_number")
        if (node.localName == 'sup' ||
            node.localName == 'small' ||
            node.className == 'verse_number') {
          // Finalize the current line if it exists
          if (currentLigne.trim().isNotEmpty) {
            currentLignes.add(currentLigne.trim());
            currentLigne = '';
          }

          // Finalize the previous verse
          finalizeVerset();

          // Start a new verse
          currentVersetNumero = int.tryParse(node.text.trim());
        }
        // If it's a <br>, it marks a new line
        else if (node.localName == 'br') {
          if (currentLigne.trim().isNotEmpty) {
            currentLignes.add(currentLigne.trim());
            currentLigne = '';
          }
        }
        // If it's a <u> (accent) or other elements, get the text
        else {
          currentLigne += _extractText(node);
        }
      }
      // If it's plain text
      else if (node is dom.Text) {
        currentLigne += node.text;
      }
    }

    // Finalize the last line and last verse
    if (currentLigne.trim().isNotEmpty) {
      currentLignes.add(currentLigne.trim());
    }
    finalizeVerset();

    return versets;
  }

  /// Extract all text from an element, including sub-elements
  String _extractText(dom.Element element) {
    final buffer = StringBuffer();
    for (var node in element.nodes) {
      if (node is dom.Text) {
        buffer.write(node.text);
      } else if (node is dom.Element) {
        buffer.write(_extractText(node));
      }
    }
    return buffer.toString();
  }

  Widget _buildPsalmContent(String? content, bool isDark) {
    if (content == null || content.isEmpty) {
      return const CorpsText('[Contenu du psaume non disponible]');
    }

    final paragraphes = _parseHtmlContent(content);

    if (paragraphes.isEmpty) {
      // Fallback to HTML widget if parsing fails
      return Html(
        data: content,
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(16),
            lineHeight: LineHeight(1.8),
            color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
          ),
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphes.asMap().entries.map((entry) {
        final index = entry.key;
        final paragraphe = entry.value;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < paragraphes.length - 1 ? 16.0 : 0,
          ),
          child: _buildParagraphe(paragraphe, isDark),
        );
      }).toList(),
    );
  }

  Widget _buildParagraphe(_Paragraphe paragraphe, bool isDark) {
    final lignesWidget = <Widget>[];

    for (var verset in paragraphe.versets) {
      for (int i = 0; i < verset.lignes.length; i++) {
        lignesWidget.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verse number (only on the first line of the verse)
              SizedBox(
                width: 40.0,
                child: i == 0
                    ? Text(
                        '${verset.numero}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 11,
                        ),
                      )
                    : const SizedBox(),
              ),
              const SizedBox(width: 8),
              // Line text
              Expanded(
                child: _buildLigneTexte(verset.lignes[i], isDark),
              ),
            ],
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lignesWidget,
    );
  }

  Widget _buildLigneTexte(String ligne, bool isDark) {
    return Text.rich(
      TextSpan(children: _parseSpecialCharacters(ligne, isDark)),
    );
  }
}
