import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_constants.dart';
import '../../domain/entities/rhyme_result.dart';






class RhymeRemoteDatasource {
  final Dio _dio;
  final Map<String, RhymeResult> _cache = {};

  RhymeRemoteDatasource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 10),
            ));

  
  
  
  
  Future<RhymeResult> fetchRhymes(String word) async {
    final key = word.toLowerCase().trim();
    if (key.isEmpty) return const RhymeResult.empty();

    if (_cache.containsKey(key)) return _cache[key]!;

    final response = await _dio.get(
      ApiConstants.scrapeRhymes,
      queryParameters: {'word': key},
    );

    final data = response.data as Map<String, dynamic>;
    final grouped = <int, List<String>>{};

    for (int i = 1; i <= 5; i++) {
      final list = data['sylab$i'];
      if (list is List && list.isNotEmpty) {
        grouped[i] = list.cast<String>();
      }
    }

    final result = RhymeResult(grouped);
    _cache[key] = result;

    debugPrint('RhymeRemoteDatasource: fetched ${result.totalCount} rhymes for "$key"');
    return result;
  }
}
