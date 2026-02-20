import 'package:flutter/foundation.dart'; 
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/rhyme_detector.dart';
import '../../../../core/utils/text_tokenizer.dart';


class AnalyzeRhymesUseCase implements UseCase<RhymeAnalysisResult, AnalyzeRhymesParams> {
  
  @override
  Future<RhymeAnalysisResult> call(AnalyzeRhymesParams params) async {
    return compute(_analyzeRhymesInIsolate, params);
  }
}


RhymeAnalysisResult _analyzeRhymesInIsolate(AnalyzeRhymesParams params) {
  final lines = params.text.split('\n');
  
  
  final stanzaRhymes = <int, Map<String, int>>{};
  
  List<String> currentStanza = [];
  int stanzaStartLine = 0;

  for (int i = 0; i < lines.length; i++) {
    
    if (lines[i].trim().isEmpty) {
      if (currentStanza.isNotEmpty) {
        _processStanza(
          currentStanza,
          stanzaStartLine,
          stanzaRhymes,
          threshold: params.threshold,
          enableAssonance: params.enableAssonance,
        );
      }
      currentStanza = [];
      stanzaStartLine = i + 1; 
    } else {
      currentStanza.add(lines[i]);
    }
    
    
    if (i == lines.length - 1 && currentStanza.isNotEmpty) {
        _processStanza(
          currentStanza,
          stanzaStartLine,
          stanzaRhymes,
          threshold: params.threshold,
          enableAssonance: params.enableAssonance,
        );
    }
  }

  return RhymeAnalysisResult(stanzaRhymes: stanzaRhymes);
}


void _processStanza(
  List<String> lines,
  int startLineIndex,
  Map<int, Map<String, int>> resultMap, {
  double threshold = 0.6,
  bool enableAssonance = true,
}) {
  
  
  final List<({String word, int lineIndex})> allWords = [];

  for (int i = 0; i < lines.length; i++) {
    final lineWords = lines[i].trim().split(RegExp(r'\s+'));
    for (var word in lineWords) {
      final clean = TextTokenizer.cleanWord(word);
      if (clean.length >= 2) {
        allWords.add((word: clean, lineIndex: startLineIndex + i));
      }
    }
  }

  
  
  
  final processed = <String>{};
  
  
  
  
  
  
  
  int maxGroupIndex = 0;
  for(var innerMap in resultMap.values) {
    if (innerMap.isNotEmpty) {
       final maxInLine = innerMap.values.reduce((curr, next) => curr > next ? curr : next);
       if (maxInLine > maxGroupIndex) maxGroupIndex = maxInLine;
    }
  }
  int groupIndex = maxGroupIndex + 1;

  
  
  
  
  for (int i = 0; i < allWords.length; i++) {
    final current = allWords[i];
    if (processed.contains(current.word)) continue;

    final group = <String>{current.word};

    for (int j = i + 1; j < allWords.length; j++) {
      final other = allWords[j];
      
      
      if (processed.contains(other.word)) continue; 
      
      if (current.word == other.word) {
        group.add(other.word);
        continue;
      }
      
      if (RhymeDetector.rhymes(current.word, other.word,
          threshold: threshold, enableAssonance: enableAssonance)) {
        group.add(other.word);
      }
    }

    if (group.length > 1) {
      
      for (var w in group) {
        processed.add(w);
        
        
        for (var token in allWords) {
          if (group.contains(token.word)) {
            resultMap.putIfAbsent(token.lineIndex, () => {});
            resultMap[token.lineIndex]![token.word] = groupIndex;
          }
        }
      }
      groupIndex++;
    }
  }
}

class AnalyzeRhymesParams {
  final String text;
  final double threshold;
  final bool enableAssonance;
  
  const AnalyzeRhymesParams({
    required this.text,
    this.threshold = 0.6,
    this.enableAssonance = true,
  });
}

class RhymeAnalysisResult {
  final Map<int, Map<String, int>> stanzaRhymes;
  
  const RhymeAnalysisResult({required this.stanzaRhymes});
}
