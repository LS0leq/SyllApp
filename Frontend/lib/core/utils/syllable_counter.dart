import 'text_tokenizer.dart';

class SyllableCounter {
  static final Set<String> vowels = {'a', 'ą', 'e', 'ę', 'i', 'o', 'ó', 'u', 'y'};
  
  static int count(String word) {
    if (word.isEmpty) return 0;
    
    final cleanWord = TextTokenizer.cleanWord(word);
    if (cleanWord.isEmpty) return 0;
    
    int syllables = 0;
    bool previousWasVowel = false;
    
    for (int i = 0; i < cleanWord.length; i++) {
      final char = cleanWord[i];
      final isVowel = vowels.contains(char);
      
      if (isVowel && !previousWasVowel) {
        syllables++;
      }
      
      previousWasVowel = isVowel;
    }
    
    return syllables == 0 ? 1 : syllables;
  }
  
  static int countInLine(String line) {
    if (line.trim().isEmpty) return 0;
    
    final words = line.split(RegExp(r'\s+'));
    return words.fold(0, (sum, word) => sum + count(word));
  }
}
