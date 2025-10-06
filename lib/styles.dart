import 'package:flutter/material.dart';

class TitreText extends StatelessWidget {
  final String text;
  const TitreText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter', // Sans serif pour les titres
        fontFeatures: const [
          FontFeature.enable('liga'), // Ligatures standard
        ],
        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F),
      ),
    );
  }
}

class SousTitreText extends StatelessWidget {
  final String text;
  const SousTitreText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter', // Sans serif pour les sous-titres
        fontFeatures: const [
          FontFeature.enable('liga'),
        ],
        color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF92400E),
      ),
    );
  }
}

class ReferenceBibliqueText extends StatelessWidget {
  final String text;
  const ReferenceBibliqueText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        // Hérite de EBGaramond du thème
        fontFeatures: const [
          FontFeature.enable('liga'), // Ligatures standard
          //FontFeature.enable('dlig'), // Ligatures discrétionnaires
          FontFeature.enable('calt'), // Alternatives contextuelles
        ],
        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
      ),
    );
  }
}

class RubriqueText extends StatelessWidget {
  final String text;
  const RubriqueText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter', // Sans serif pour les rubriques
        fontFeatures: const [
          FontFeature.enable('liga'),
        ],
        color: isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
      ),
    );
  }
}

class CorpsText extends StatelessWidget {
  final String text;
  const CorpsText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 17,
        height: 1.3,
        // Hérite de EBGaramond du thème
        fontFeatures: const [
          FontFeature.enable(
              'liga'), // Ligatures standard (fi, fl, ff, ffi, ffl)
          // FontFeature.enable(
          //     'dlig'), // Ligatures discrétionnaires (ct, st, sp, etc.)
          FontFeature.enable('calt'), // Alternatives contextuelles
          FontFeature.enable('hlig'), // Ligatures historiques
        ],
        color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
      ),
    );
  }
}
