class HtmlCleaner {
  const HtmlCleaner._();

  static String text(String? html) {
    if (html == null || html.trim().isEmpty) return '';
    return html
        .replaceAll(RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8217;', '’')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
