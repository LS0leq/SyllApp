import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';





class PolishWordsDatasource {
  static const _assetPath = 'assets/polish_words.txt';

  List<String>? _cachedWords;

  
  Future<List<String>> getWords() async {
    if (_cachedWords != null) return _cachedWords!;

    try {
      final raw = await rootBundle.loadString(_assetPath);
      _cachedWords = raw
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toSet() 
          .toList();
      debugPrint('PolishWordsDatasource: loaded ${_cachedWords!.length} words');
    } catch (e) {
      debugPrint('PolishWordsDatasource: failed to load asset: $e');
      _cachedWords = const [];
    }

    return _cachedWords!;
  }
}
