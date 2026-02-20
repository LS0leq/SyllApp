import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/syllable_counter.dart';


class CountSyllablesUseCase implements UseCase<SyllableCountResult, CountSyllablesParams> {
  
  @override
  Future<SyllableCountResult> call(CountSyllablesParams params) async {
    final lines = params.text.split('\n');
    
    int totalSyllables = 0;
    List<int> syllablesPerLine = [];
    int nonEmptyLines = 0;
    
    for (final line in lines) {
      final count = SyllableCounter.countInLine(line);
      syllablesPerLine.add(count);
      totalSyllables += count;
      if (line.trim().isNotEmpty) nonEmptyLines++;
    }
    
    final average = nonEmptyLines > 0 ? totalSyllables / nonEmptyLines : 0.0;
    
    return SyllableCountResult(
      totalSyllables: totalSyllables,
      syllablesPerLine: syllablesPerLine,
      averageSyllablesPerLine: average,
      lineCount: lines.length,
    );
  }
}

class CountSyllablesParams {
  final String text;
  
  const CountSyllablesParams({required this.text});
}

class SyllableCountResult {
  final int totalSyllables;
  final List<int> syllablesPerLine;
  final double averageSyllablesPerLine;
  final int lineCount;
  
  const SyllableCountResult({
    required this.totalSyllables,
    required this.syllablesPerLine,
    required this.averageSyllablesPerLine,
    required this.lineCount,
  });
}
