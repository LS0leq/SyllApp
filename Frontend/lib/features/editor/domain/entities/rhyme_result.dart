





class RhymeResult {
  
  
  final Map<int, List<String>> bySyllableCount;

  const RhymeResult(this.bySyllableCount);

  const RhymeResult.empty() : bySyllableCount = const {};

  
  RhymeResult.ungrouped(List<String> words)
      : bySyllableCount = words.isEmpty ? const {} : {0: words};

  
  List<String> get flat =>
      bySyllableCount.values.expand((v) => v).toList();

  
  bool get isEmpty =>
      bySyllableCount.isEmpty ||
      bySyllableCount.values.every((v) => v.isEmpty);

  bool get isNotEmpty => !isEmpty;

  
  bool get isGrouped =>
      bySyllableCount.keys.any((k) => k > 0);

  
  int get totalCount =>
      bySyllableCount.values.fold(0, (sum, v) => sum + v.length);
}
