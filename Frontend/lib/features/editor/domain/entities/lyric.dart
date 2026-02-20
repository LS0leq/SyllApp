import '../../../../core/utils/syllable_counter.dart';
import '../../../../core/utils/rhyme_detector.dart';
import 'verse.dart';



class Lyric {
  final List<Verse> verses;
  
  Lyric({List<Verse>? verses}) : verses = verses ?? [];
  
  
  void updateFromLines(List<String> lines, {bool analyzeRhymes = true}) {
    verses.clear();
    for (int i = 0; i < lines.length; i++) {
      final count = SyllableCounter.countInLine(lines[i]);
      verses.add(Verse(
        text: lines[i], 
        lineNumber: i + 1,
        syllableCount: count,
      ));
    }
    if (analyzeRhymes) {
      _detectRhymes();
    }
  }
  
  void _detectRhymes() {
    final lines = verses.map((v) => v.text).toList();
    final rhymeGroups = RhymeDetector.detectRhymeScheme(lines);
    
    int groupIndex = 0;
    for (var entry in rhymeGroups.entries) {
      if (entry.value.length > 1) {
        for (var lineIndex in entry.value) {
          if (lineIndex < verses.length) {
            verses[lineIndex].rhymeGroup = groupIndex;
          }
        }
        groupIndex++;
      }
    }
  }
  
  
  String get rhymeScheme {
    final lines = verses.map((v) => v.text).toList();
    return RhymeDetector.getRhymeSchemePattern(lines);
  }
  
  
  List<List<String>> get rhymeGroups {
    final lines = verses.map((v) => v.text).toList();
    final detected = RhymeDetector.detectRhymeScheme(lines);
    
    List<List<String>> groups = [];
    for (var entry in detected.entries) {
      if (entry.value.length > 1) {
        List<String> words = [];
        for (var lineIndex in entry.value) {
          if (lineIndex < verses.length) {
            final word = verses[lineIndex].lastWord;
            if (word.isNotEmpty && !words.contains(word)) {
              words.add(word);
            }
          }
        }
        if (words.length > 1) {
          groups.add(words);
        }
      }
    }
    return groups;
  }
  
  
  int get totalSyllables => verses.fold(0, (sum, v) => sum + v.syllableCount);
  
  
  double get averageSyllables {
    final nonEmpty = verses.where((v) => v.text.trim().isNotEmpty);
    if (nonEmpty.isEmpty) return 0;
    return nonEmpty.fold(0, (sum, v) => sum + v.syllableCount) / nonEmpty.length;
  }
  
  
  int get lineCount => verses.length;
  
  
  int getSyllableCount(int verseIndex) {
    if (verseIndex < 0 || verseIndex >= verses.length) return 0;
    return verses[verseIndex].syllableCount;
  }
}
