import '../../../../core/utils/text_tokenizer.dart';



class Verse {
  final String text;
  final int lineNumber;
  final int? _syllableCount;
  int? rhymeGroup;
  
  Verse({
    required this.text,
    required this.lineNumber,
    int? syllableCount,
    this.rhymeGroup,
  }) : _syllableCount = syllableCount;
  
  int get syllableCount => _syllableCount ?? 0;
  
  
  String get lastWord {
    return TextTokenizer.getLastWord(text);
  }
  
  bool get isEmpty => text.trim().isEmpty;
}
