/// Helper functions for HTML content processing and display

/// Prepare liturgical HTML content for proper display
String prepareLiturgicalHtml(String content) {
  String html = content.trim();

  // If content doesn't start with HTML tags, wrap it
  if (!html.startsWith('<')) {
    html = '<div>$html</div>';
  }

  // Normalize line breaks
  html = html.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  // Convert double line breaks to paragraph breaks
  html = html.replaceAll('\n\n', '</p><p>');

  // Convert single line breaks to <br> tags
  html = html.replaceAll('\n', '<br>');

  // Ensure paragraphs are properly wrapped
  if (!html.contains('<p>')) {
    html = '<p>$html</p>';
  }

  // Fix common HTML entities that might not be encoded
  html = _fixHtmlEntities(html);

  return html;
}

/// Fix common HTML entities and special characters
String _fixHtmlEntities(String html) {
  return html
          // Quotes
          .replaceAll(''', '&rsquo;')
      .replaceAll(''', '&lsquo;')
          .replaceAll('"', '&ldquo;')
          .replaceAll('"', '&rdquo;')
          // Spaces
          .replaceAll(' ', '&nbsp;')
      // Already encoded entities - leave as is
      ;
}

/// Clean HTML for simple text display (remove all tags)
String stripHtmlTags(String html) {
  return html
      .replaceAll(RegExp(r'<br\s*/?>'), '\n')
      .replaceAll(RegExp(r'<p>'), '\n')
      .replaceAll(RegExp(r'</p>'), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&eacute;', 'é')
      .replaceAll('&egrave;', 'è')
      .replaceAll('&ecirc;', 'ê')
      .replaceAll('&agrave;', 'à')
      .replaceAll('&acirc;', 'â')
      .replaceAll('&ocirc;', 'ô')
      .replaceAll('&ucirc;', 'û')
      .replaceAll('&ugrave;', 'ù')
      .replaceAll('&ccedil;', 'ç')
      .replaceAll('&icirc;', 'î')
      .replaceAll('&iuml;', 'ï')
      .replaceAll('&euml;', 'ë')
      .replaceAll('&rsquo;', '\'')
      .replaceAll('&lsquo;', '\'')
      .replaceAll('&rdquo;', '"')
      .replaceAll('&ldquo;', '"')
      .replaceAll('&aelig;', 'æ')
      .replaceAll('&oelig;', 'œ')
      .trim();
}

/// Extract plain text from HTML content
String htmlToPlainText(String html) {
  return stripHtmlTags(html)
      .replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n') // Max 2 consecutive newlines
      .trim();
}

/// Wrap text content with proper HTML structure
String wrapInHtml(String text) {
  // Split by double newlines for paragraphs
  List<String> paragraphs = text.split('\n\n');

  String html = paragraphs.map((p) {
    // Replace single newlines with <br> within paragraphs
    String content = p.trim().replaceAll('\n', '<br>');
    return '<p>$content</p>';
  }).join('');

  return html;
}

/// Format verse references (e.g., "Ps 23, 1-6")
String formatBiblicalReference(String? reference) {
  if (reference == null || reference.isEmpty) return '';
  return reference.trim();
}

/// Normalize spaces and special characters in liturgical text
String normalizeLiturgicalText(String text) {
  return text
      .replaceAll(RegExp(r'\s+'), ' ') // Multiple spaces to single space
      .replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n') // Max 2 newlines
      .trim();
}
