import 'package:dio/dio.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/api_constants.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';


class AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSource(this._dio);

  
  Future<Result<({UserModel user, AuthTokensModel tokens})>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      final data = response.data as Map<String, dynamic>;

      
      final tokens = AuthTokensModel.fromJson(data);

      
      
      final user = data.containsKey('user') && data['user'] is Map<String, dynamic>
          ? UserModel.fromJson(data['user'] as Map<String, dynamic>)
          : UserModel(id: '', username: username);

      return Success((user: user, tokens: tokens));
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    }
  }

  
  Future<Result<({UserModel user, AuthTokensModel tokens})>> register(
    String username,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'name': username,
          'password': password,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data);

      
      final loginResult = await login(username, password);
      if (loginResult is Success<({UserModel user, AuthTokensModel tokens})>) {
        
        return Success((
          user: user,
          tokens: loginResult.value.tokens,
        ));
      } else {
        
        final failure = (loginResult as Err).failure;
        return Err(AuthFailure(
          'Rejestracja udana, ale auto-logowanie nie powiodło się: ${failure.message}',
        ));
      }
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    }
  }

  
  Future<Result<AuthTokensModel>> refreshTokens(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      return Success(AuthTokensModel.fromJson(data));
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    }
  }

  
  Future<Result<void>> logout(String refreshToken) async {
    try {
      await _dio.post(
        ApiConstants.logout,
        data: {'refresh_token': refreshToken},
      );
      return const Success(null);
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    }
  }

  Failure _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    
    String message = 'Nieoczekiwany błąd serwera';
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

    if (statusCode == 401 || statusCode == 403) {
      return AuthFailure(message);
    }
    return NetworkFailure(message, statusCode: statusCode);
  }
}
