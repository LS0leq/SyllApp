import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_constants.dart';
import 'auth_interceptor.dart';




class ApiClient {
  final Dio dio;

  ApiClient({required AuthInterceptor authInterceptor})
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            sendTimeout: ApiConstants.sendTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(authInterceptor);

    
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ));
    }
  }
}
