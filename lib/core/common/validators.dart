bool isValidUrlFormat(String url) {
  final uri = Uri.tryParse(url);

  final isValidScheme = uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  final hasWww = url.contains('www.');

  return isValidScheme && hasWww;
}