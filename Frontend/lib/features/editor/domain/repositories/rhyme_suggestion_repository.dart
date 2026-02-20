import '../entities/rhyme_result.dart';





abstract class RhymeSuggestionRepository {
  
  
  
  
  Future<RhymeResult> getRhymeSuggestions(String word);

  
  Future<List<String>> getAutocompleteSuggestions(String prefix);
}
