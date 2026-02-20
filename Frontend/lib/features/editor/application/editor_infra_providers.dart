import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_health_service.dart';
import '../domain/repositories/lyrics_repository.dart';
import '../domain/repositories/rhyme_suggestion_repository.dart';
import '../domain/usecases/analyze_rhymes.dart';
import '../data/datasources/rhyme_remote_datasource.dart';
import '../data/repositories/lyrics_repository_factory_stub.dart'
    if (dart.library.io) '../data/repositories/lyrics_repository_factory_native.dart'
    if (dart.library.html) '../data/repositories/lyrics_repository_factory_web.dart';
import '../data/repositories/rhyme_suggestion_repository_impl.dart';



final lyricsRepositoryProvider = Provider<LyricsRepository>((ref) {
  return createLyricsRepository();
});


final analyzeRhymesUseCaseProvider = Provider<AnalyzeRhymesUseCase>((ref) {
  return AnalyzeRhymesUseCase();
});


final apiHealthServiceProvider = Provider<ApiHealthService>((ref) {
  return ApiHealthService();
});


final rhymeRemoteDatasourceProvider = Provider<RhymeRemoteDatasource>((ref) {
  return RhymeRemoteDatasource();
});


final rhymeSuggestionRepositoryProvider =
    Provider<RhymeSuggestionRepository>((ref) {
  return RhymeSuggestionRepositoryImpl(
    remoteDatasource: ref.read(rhymeRemoteDatasourceProvider),
    healthService: ref.read(apiHealthServiceProvider),
  );
});
