import 'package:flutter/foundation.dart';
import '../../../../core/network/api_health_service.dart';
import '../../../../core/utils/rhyme_detector.dart';
import '../../domain/entities/rhyme_result.dart';
import '../../domain/repositories/rhyme_suggestion_repository.dart';
import '../datasources/rhyme_api_datasource.dart';
import '../datasources/rhyme_remote_datasource.dart';





class RhymeSuggestionRepositoryImpl implements RhymeSuggestionRepository {
  final PolishWordsDatasource _localDatasource;
  final RhymeRemoteDatasource _remoteDatasource;
  final ApiHealthService _healthService;

  RhymeSuggestionRepositoryImpl({
    required RhymeRemoteDatasource remoteDatasource,
    required ApiHealthService healthService,
    PolishWordsDatasource? localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _healthService = healthService,
        _localDatasource = localDatasource ?? PolishWordsDatasource();

  @override
  Future<RhymeResult> getRhymeSuggestions(String word) async {
    if (word.isEmpty) return const RhymeResult.empty();

    
    final apiUp = await _healthService.checkHealth();
    if (apiUp) {
      try {
        return await _remoteDatasource.fetchRhymes(word);
      } catch (e) {
        debugPrint('RhymeSuggestionRepo: API call failed, falling back to local ($e)');
      }
    }

    
    return _getLocalRhymes(word);
  }

  Future<RhymeResult> _getLocalRhymes(String word) async {
    final words = await _localDatasource.getWords();
    final lowerWord = word.toLowerCase();

    final seen = <String>{};
    final results = <String>[];

    for (final candidate in words) {
      final lowerCandidate = candidate.toLowerCase();
      if (lowerCandidate == lowerWord) continue;
      if (seen.contains(lowerCandidate)) continue;

      if (RhymeDetector.rhymes(candidate, word)) {
        seen.add(lowerCandidate);
        results.add(candidate);
        if (results.length >= 15) break;
      }
    }

    return RhymeResult.ungrouped(results);
  }

  @override
  Future<List<String>> getAutocompleteSuggestions(String prefix) async {
    if (prefix.isEmpty) return [];

    final words = await _localDatasource.getWords();
    final lowerPrefix = prefix.toLowerCase();

    return words
        .where((w) => w.toLowerCase().startsWith(lowerPrefix))
        .where((w) => w.toLowerCase() != lowerPrefix)
        .take(5)
        .toList();
  }
}
