import 'package:dio/dio.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/api_constants.dart';
import '../../domain/repositories/cloud_project_repository.dart';


class CloudProjectDataSource {
  final Dio _dio;
  CloudProjectDataSource(this._dio);

  
  Future<Result<List<CloudProject>>> fetchProjects({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.projects,
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final list = (response.data as List)
          .map((e) => _mapProject(e as Map<String, dynamic>))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      return Err(_mapError(e));
    }
  }

  
  Future<Result<CloudProject>> createProject(
    String name,
    String content,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.projects,
        data: {'name': name, 'text': content},
      );
      return Success(_mapProject(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(_mapError(e));
    }
  }

  
  Future<Result<CloudProject>> updateProject(
    String id, {
    String? name,
    String? content,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (content != null) data['text'] = content;

      final response = await _dio.put(
        ApiConstants.projectById(id),
        data: data,
      );
      return Success(_mapProject(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(_mapError(e));
    }
  }

  
  Future<Result<void>> deleteProject(String id) async {
    try {
      await _dio.delete(ApiConstants.projectById(id));
      return const Success(null);
    } on DioException catch (e) {
      return Err(_mapError(e));
    }
  }

  
  Future<Result<CloudProject>> getProject(String id) async {
    try {
      final response = await _dio.get(ApiConstants.projectById(id));
      return Success(_mapProject(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(_mapError(e));
    }
  }

  CloudProject _mapProject(Map<String, dynamic> json) {
    return CloudProject(
      id: (json['idNote'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '') as String,
      text: (json['text'] ?? '') as String,
      userId: (json['idUser'] ?? json['userId'] ?? '').toString(),
    );
  }

  Failure _mapError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    String message = 'Błąd serwera';
    if (data is Map<String, dynamic>) {
      if (data.containsKey('detail')) {
        final detail = data['detail'];
        message = detail is String ? detail : detail.toString();
      } else if (data.containsKey('message')) {
        message = data['message'] as String;
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      message = 'Serwer się uruchamia... Spróbuj ponownie za chwilę';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'Brak połączenia z serwerem';
    }

    return NetworkFailure(message, statusCode: statusCode);
  }
}
