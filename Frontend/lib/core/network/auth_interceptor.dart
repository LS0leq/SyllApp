import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_constants.dart';


typedef TokenReader = Future<String?> Function();


typedef RefreshTokenReader = Future<String?> Function();


typedef TokenWriter = Future<void> Function(String accessToken, String refreshToken);


typedef OnAuthFailure = Future<void> Function();





class AuthInterceptor extends Interceptor {
  final TokenReader readAccessToken;
  final RefreshTokenReader readRefreshToken;
  final TokenWriter writeTokens;
  final OnAuthFailure onAuthFailure;

  
  late final Dio _refreshDio;

  bool _isRefreshing = false;

  AuthInterceptor({
    required this.readAccessToken,
    required this.readRefreshToken,
    required this.writeTokens,
    required this.onAuthFailure,
  }) {
    _refreshDio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 || _isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;
    try {
      final refreshToken = await readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await onAuthFailure();
        return handler.next(err);
      }

      final response = await _refreshDio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      final newAccess = (response.data['access_token'] ?? response.data['accessToken']) as String;
      final newRefresh = (response.data['refresh_token'] ?? response.data['refreshToken']) as String;
      await writeTokens(newAccess, newRefresh);

      
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccess';

      final retryResponse = await _refreshDio.fetch(opts);
      return handler.resolve(retryResponse);
    } on DioException catch (refreshErr) {
      debugPrint('[AuthInterceptor] Refresh failed: $refreshErr');
      await onAuthFailure();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
