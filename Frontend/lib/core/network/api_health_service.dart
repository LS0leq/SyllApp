import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_constants.dart';





class ApiHealthService {
  final Dio _dio;

  bool? _lastResult;
  DateTime? _lastCheck;
  static const _cacheDuration = Duration(seconds: 30);

  ApiHealthService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3),
            ));

  
  bool get isAvailable => _lastResult ?? false;

  
  Future<bool> checkHealth() async {
    if (_lastCheck != null &&
        DateTime.now().difference(_lastCheck!) < _cacheDuration) {
      return _lastResult!;
    }

    try {
      
      final response = await _dio.get(
        ApiConstants.scrapeRhymes,
        queryParameters: {'word': 'test'},
      );
      _lastResult = response.statusCode == 200;
    } catch (e) {
      debugPrint('ApiHealthService: API unreachable ($e)');
      _lastResult = false;
    }

    _lastCheck = DateTime.now();
    return _lastResult!;
  }

  
  void invalidate() {
    _lastResult = null;
    _lastCheck = null;
  }
}
