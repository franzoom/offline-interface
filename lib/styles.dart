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
        fontSize: 16,
        height: 1.6,
        color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
      ),
    );
  }
}
