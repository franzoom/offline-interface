import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

/// ============================================
/// LITURGY TEXT PARSER
/// Reusable parser for psalms, hymns, responsories, and other liturgical texts
/// ============================================

/// Represents a verse with its number and text lines
class Verset {
  final int numero;
  final List<String> lignes;

  Verset({
    required this.numero,
    required this.lignes,
  });
}

/// Represents a paragraph containing one or more verses
class Paragraphe {
  final List<Verset> versets;

  Paragraphe({required this.versets});
}

/// Configuration for special character colors
class LiturgyParserConfig {
  /// Color for verse numbers and special symbols (+, *, ℟, ℣)
  static const Color couleurRouge = Colors.red;

  /// Font size for verse numbers
  static const double tailleNumero = 11.0;

  /// Font size for verse text
  static const double tailleTexte = 16.0;

  /// Width reserved for verse numbers (in pixels)
  static const double largeurNumero = 40.0;

  /// Font weight for special characters (+, *, ℟, ℣)
  static const FontWeight grasFaibleSymboles = FontWeight.w500;

  /// Font weight for verse numbers
  static const FontWeight grasNumeros = FontWeight.bold;

  /// Spacing between verse number and text (in pixels)
  static const double espacementNumeroTexte = 8.0;

  /// Line height for text
  static const double espacementLignes = 1.4;

  /// Spacing between paragraphs (in pixels)
  static const double espacementParagraphes = 16.0;
}

/// Main parser class for liturgical texts
class LiturgyParser {
  /// Parse special characters in text (R/, V/, *, +) and apply formatting
  ///
  /// Converts:
  /// - R/ → ℟ (in red)
  /// - V/ → ℣ (in red)
  /// - * → * (in red)
  /// - + → + (in red)
  /// - Adds non-breaking spaces before * and + to prevent orphan characters
  ///
  /// Parameters:
  /// - [text]: The text to parse
  /// - [isDark]: Whether dark mode is active
  /// - [fontSize]: Font size for the text (default: 16)
  /// - [isItalic]: Whether text should be italic (default: false)
  /// - [textColor]: Optional custom text color (uses theme colors if null)
  ///
  /// Returns a list of [TextSpan] with proper formatting
  static List<TextSpan> parseSpecialCharacters(
    String text,
    bool isDark, {
    double fontSize = 16,
    bool isItalic = false,
    Color? textColor,
  }) {
    // Replace R/ with ℟ and V/ with ℣
    text = text.replaceAll('R/', '℟').replaceAll('V/', '℣');

    // Replace regular spaces before * or + with non-breaking spaces
    // to prevent orphan characters at line start
    text = text.replaceAll(' *', '\u00A0*');
    text = text.replaceAll(' +', '\u00A0+');

    final spans = <TextSpan>[];
    final buffer = StringBuffer();

    // Determine text color based on theme if not provided
    final normalColor = textColor ??
        (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151));

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (char == '+' || char == '*' || char == '℟' || char == '℣') {
        // Add accumulated text in normal color
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(
            text: buffer.toString(),
            style: TextStyle(
              fontSize: fontSize,
              height: LiturgyParserConfig.espacementLignes,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              color: normalColor,
            ),
          ));
          buffer.clear();
        }

        // Add the special character in red
        spans.add(TextSpan(
          text: char,
          style: TextStyle(
            fontSize: fontSize,
            height: LiturgyParserConfig.espacementLignes,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            color: LiturgyParserConfig.couleurRouge,
            fontWeight: LiturgyParserConfig.grasFaibleSymboles,
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
          height: LiturgyParserConfig.espacementLignes,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          color: normalColor,
        ),
      ));
    }

    return spans;
  }

  /// Build a Text.rich widget from special character parsing
  ///
  /// Convenience method that wraps [parseSpecialCharacters] in a Text.rich widget
  static Widget buildParsedText(
    String text,
    bool isDark, {
    double fontSize = 16,
    bool isItalic = false,
    Color? textColor,
  }) {
    return Text.rich(
      TextSpan(
        children: parseSpecialCharacters(
          text,
          isDark,
          fontSize: fontSize,
          isItalic: isItalic,
          textColor: textColor,
        ),
      ),
    );
  }

  /// Parse HTML content to extract verses and paragraphs
  ///
  /// Parses HTML structure looking for:
  /// - <p> elements as paragraphs
  /// - <sup>, <small>, or class="verse_number" as verse numbers
  /// - <br> as line breaks
  ///
  /// Returns a list of [Paragraphe] objects containing structured verse data
  static List<Paragraphe> parseHtmlContent(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    final paragraphes = <Paragraphe>[];

    // Get all <p> elements (one <p> = one paragraph)
    final pElements = document.querySelectorAll('p');

    for (var pElement in pElements) {
      final versets = _parseParagraphe(pElement);
      if (versets.isNotEmpty) {
        paragraphes.add(Paragraphe(versets: versets));
      }
    }

    return paragraphes;
  }

  /// Parse a <p> element and extract all verses it contains
  static List<Verset> _parseParagraphe(dom.Element pElement) {
    final versets = <Verset>[];
    int? currentVersetNumero;
    List<String> currentLignes = [];

    void finalizeVerset() {
      if (currentVersetNumero != null && currentLignes.isNotEmpty) {
        versets.add(Verset(
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
  static String _extractText(dom.Element element) {
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

  /// Build a verse line widget with number on the left
  ///
  /// Creates a Row with:
  /// - Verse number aligned right in a fixed-width container (only on first line)
  /// - Parsed text content with special characters in red
  ///
  /// Parameters:
  /// - [versetNumero]: The verse number
  /// - [ligne]: The text line
  /// - [isDark]: Whether dark mode is active
  /// - [isFirstLine]: Whether this is the first line of the verse (shows number)
  /// - [numeroWidth]: Width reserved for numbers (default: from config)
  /// - [numeroSpacing]: Space between number and text (default: from config)
  static Widget buildVerseLine({
    required int versetNumero,
    required String ligne,
    required bool isDark,
    required bool isFirstLine,
    double? numeroWidth,
    double? numeroSpacing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Verse number (only on the first line)
        SizedBox(
          width: numeroWidth ?? LiturgyParserConfig.largeurNumero,
          child: isFirstLine
              ? Text(
                  '$versetNumero',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: LiturgyParserConfig.grasNumeros,
                    color: LiturgyParserConfig.couleurRouge,
                    fontSize: LiturgyParserConfig.tailleNumero,
                  ),
                )
              : const SizedBox(),
        ),
        SizedBox(
            width: numeroSpacing ?? LiturgyParserConfig.espacementNumeroTexte),
        // Line text with parsed special characters
        Expanded(
          child: buildParsedText(
            ligne,
            isDark,
            fontSize: LiturgyParserConfig.tailleTexte,
          ),
        ),
      ],
    );
  }

  /// Build a complete paragraph widget with all its verses
  ///
  /// Parameters:
  /// - [paragraphe]: The paragraph data
  /// - [isDark]: Whether dark mode is active
  static Widget buildParagraphe({
    required Paragraphe paragraphe,
    required bool isDark,
  }) {
    final lignesWidget = <Widget>[];

    for (var verset in paragraphe.versets) {
      for (int i = 0; i < verset.lignes.length; i++) {
        lignesWidget.add(
          buildVerseLine(
            versetNumero: verset.numero,
            ligne: verset.lignes[i],
            isDark: isDark,
            isFirstLine: i == 0,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lignesWidget,
    );
  }

  /// Build complete structured content from HTML
  ///
  /// Parses HTML and builds a complete widget with all paragraphs
  ///
  /// Parameters:
  /// - [htmlContent]: The HTML content to parse
  /// - [isDark]: Whether dark mode is active
  /// - [onParseError]: Optional callback for parse errors
  static Widget buildFromHtml({
    required String htmlContent,
    required bool isDark,
    Widget Function()? onParseError,
  }) {
    final paragraphes = parseHtmlContent(htmlContent);

    if (paragraphes.isEmpty && onParseError != null) {
      return onParseError();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphes.asMap().entries.map((entry) {
        final index = entry.key;
        final paragraphe = entry.value;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < paragraphes.length - 1
                ? LiturgyParserConfig.espacementParagraphes
                : 0,
          ),
          child: buildParagraphe(
            paragraphe: paragraphe,
            isDark: isDark,
          ),
        );
      }).toList(),
    );
  }

  /// Clean HTML tags from text and preserve line breaks
  ///
  /// Removes all HTML tags while preserving intentional line breaks.
  /// Also handles common HTML entities (&nbsp;, &amp;, etc.)
  ///
  /// Parameters:
  /// - [html]: The HTML string to clean
  ///
  /// Returns cleaned plain text with line breaks preserved
  static String cleanHtmlTags(String html) {
    // Remove HTML tags but preserve line breaks
    String text = html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");

    // Clean up extra whitespace while preserving intentional line breaks
    text = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n');

    return text;
  }

  /// Parse HTML by paragraphs and return list of plain text stanzas
  ///
  /// Useful for content without verse numbers (hymns, prayers)
  ///
  /// Parameters:
  /// - [htmlContent]: The HTML content to parse
  ///
  /// Returns list of plain text strings (one per paragraph)
  static List<String> parseHtmlParagraphs(String htmlContent) {
    final RegExp pTagRegex = RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true);
    final matches = pTagRegex.allMatches(htmlContent);

    if (matches.isEmpty) {
      // If no <p> tags, return entire content as one block
      final cleanText = cleanHtmlTags(htmlContent);
      return cleanText.isEmpty ? [] : [cleanText];
    }

    final stanzas = <String>[];

    for (var match in matches) {
      final paragraphHtml = match.group(1) ?? '';
      final cleanText = cleanHtmlTags(paragraphHtml);

      if (cleanText.trim().isNotEmpty) {
        stanzas.add(cleanText);
      }
    }

    return stanzas;
  }

  /// Build content by stanzas (for hymns without verse numbers)
  ///
  /// Parses HTML into paragraphs and renders each as a parsed text block
  ///
  /// Parameters:
  /// - [htmlContent]: The HTML content to parse
  /// - [isDark]: Whether dark mode is active
  /// - [fontSize]: Font size for the text (default: 16)
  /// - [stanzaSpacing]: Spacing between stanzas in pixels (default: 12)
  static Widget buildByStanzas({
    required String htmlContent,
    required bool isDark,
    double fontSize = 16,
    double stanzaSpacing = 12,
  }) {
    final stanzas = parseHtmlParagraphs(htmlContent);

    if (stanzas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stanzas.asMap().entries.map((entry) {
        final index = entry.key;
        final stanza = entry.value;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < stanzas.length - 1 ? stanzaSpacing : 0,
          ),
          child: buildParsedText(stanza, isDark, fontSize: fontSize),
        );
      }).toList(),
    );
  }
}
