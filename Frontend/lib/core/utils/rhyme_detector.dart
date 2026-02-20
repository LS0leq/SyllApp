import 'text_tokenizer.dart';







class RhymeDetector {
  
  
  static String getLastWord(String line) {
    return TextTokenizer.getLastWord(line);
  }
  
  
  
  static String getRhymePart(String word) {
    if (word.isEmpty) return '';
    
    final lower = word.toLowerCase();
    
    
    if (lower.length <= 3) return lower;
    
    
    int lastVowelPos = -1;
    for (int i = lower.length - 1; i >= 0; i--) {
      if (_isVowel(lower[i])) {
        lastVowelPos = i;
        break;
      }
    }
    
    if (lastVowelPos == -1) return lower; 
    
    
    int secondVowelPos = -1;
    for (int i = lastVowelPos - 1; i >= 0; i--) {
      if (_isVowel(lower[i])) {
        secondVowelPos = i;
        break;
      }
    }
    
    
    if (secondVowelPos >= 0 && (lower.length - secondVowelPos) >= 3) {
      return lower.substring(secondVowelPos);
    }
    
    
    return lower.substring(lastVowelPos);
  }
  
  
  
  
  
  
  
  
  
  static bool rhymes(String word1, String word2, {
    double threshold = 0.6, 
    bool enableAssonance = true,
  }) {
    if (word1.isEmpty || word2.isEmpty) return false;
    
    final w1 = word1.toLowerCase();
    final w2 = word2.toLowerCase();
    
    
    if (w1 == w2) return true;
    
    
    final rhyme1 = getRhymePart(w1);
    final rhyme2 = getRhymePart(w2);
    
    
    if (rhyme1 == rhyme2 && rhyme1.length >= 2) return true;
    
    
    final endingSimilarity = _calculateEndingSimilarity(rhyme1, rhyme2);
    
    
    
    
    if (endingSimilarity >= threshold) return true;
    
    
    if (enableAssonance) {
      final assonanceSimilarity = _calculateAssonance(w1, w2);
      
      if (assonanceSimilarity >= 0.7 && w1.length >= 3 && w2.length >= 3) {
        
        
        if ((w1.length - w2.length).abs() <= 2) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  
  static double _calculateEndingSimilarity(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    if (s1 == s2) return 1.0;
    
    int matchCount = 0;
    final len1 = s1.length;
    final len2 = s2.length;
    final minLen = len1 < len2 ? len1 : len2;
    
    
    for (int i = 0; i < minLen; i++) {
      if (s1[len1 - 1 - i] == s2[len2 - 1 - i]) {
        matchCount++;
      } else {
        break; 
      }
    }
    
    
    if (matchCount < 2) return 0.0;
    
    
    final maxLen = len1 > len2 ? len1 : len2;
    return matchCount / maxLen;
  }
  
  
  static double _calculateAssonance(String w1, String w2) {
    final vowels1 = _extractVowels(w1);
    final vowels2 = _extractVowels(w2);
    
    if (vowels1.isEmpty || vowels2.isEmpty) return 0.0;
    if (vowels1 == vowels2) return 1.0;
    
    
    if (vowels1.length < 2 || vowels2.length < 2) return 0.0;
    
    
    int matchCount = 0;
    final len1 = vowels1.length;
    final len2 = vowels2.length;
    final minLen = len1 < len2 ? len1 : len2;
    
    for (int i = 0; i < minLen; i++) {
      if (vowels1[len1 - 1 - i] == vowels2[len2 - 1 - i]) {
        matchCount++;
      } else {
        break; 
      }
    }
    
    
    if (matchCount < 2) return 0.0;
    
    final maxLen = len1 > len2 ? len1 : len2;
    return matchCount / maxLen;
  }
  
  
  static String _extractVowels(String word) {
    final buffer = StringBuffer();
    for (final char in word.toLowerCase().split('')) {
      if (_isVowel(char)) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
  
  
  static bool _isVowel(String char) {
    return 'aeiouyąęó'.contains(char.toLowerCase());
  }
  
  
  
  static Map<String, List<int>> detectRhymeScheme(List<String> lines, {
    double threshold = 0.6,
    bool enableAssonance = true,
  }) {
    Map<String, List<int>> rhymeGroups = {};
    
    for (int i = 0; i < lines.length; i++) {
      final lastWord = getLastWord(lines[i]);
      if (lastWord.isEmpty) continue;
      
      final rhymePart = getRhymePart(lastWord);
      
      bool foundGroup = false;
      for (var entry in rhymeGroups.entries) {
        final groupWord = getLastWord(lines[entry.value.first]);
        if (rhymes(lastWord, groupWord, 
            threshold: threshold, 
            enableAssonance: enableAssonance)) {
          entry.value.add(i);
          foundGroup = true;
          break;
        }
      }
      
      if (!foundGroup) {
        rhymeGroups[rhymePart] = [i];
      }
    }
    
    return rhymeGroups;
  }
  
  
  static String getRhymeSchemePattern(List<String> lines, {
    double threshold = 0.6,
    bool enableAssonance = true,
  }) {
    final rhymeGroups = detectRhymeScheme(lines,
        threshold: threshold, enableAssonance: enableAssonance);
    final lineToGroup = <int, String>{};
    
    int groupIndex = 0;
    for (var entry in rhymeGroups.entries) {
      if (entry.value.length > 1) {
        final label = String.fromCharCode(65 + groupIndex);
        for (var lineIndex in entry.value) {
          lineToGroup[lineIndex] = label;
        }
        groupIndex++;
      }
    }
    
    final pattern = List.generate(lines.length, (i) => lineToGroup[i] ?? '-');
    return pattern.join('');
  }
}
