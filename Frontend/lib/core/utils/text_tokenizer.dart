



class TextTokenizer {
  
  static final RegExp _nonAlphaRegex = RegExp(r'[^a-ząćęłńóśźż]');

  
  static String cleanWord(String word) {
    return word.toLowerCase().replaceAll(_nonAlphaRegex, '');
  }

  
  
  
  static String getLastWord(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return '';

    final words = trimmed.split(RegExp(r'\s+'));
    return cleanWord(words.last);
  }

  
  static List<String> extractWords(String line) {
    final raw = line.trim().split(RegExp(r'\s+'));
    return raw.map(cleanWord).where((w) => w.isNotEmpty).toList();
  }
}
