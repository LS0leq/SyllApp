import 'package:flutter/foundation.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<Result<User>> login(String username, String password) async {
    final result = await _remote.login(username, password);
    return switch (result) {
      Success(:final value) => _handleAuthSuccess(value.user, value.tokens),
      Err(:final failure) => Err(failure),
    };
  }

  @override
  Future<Result<User>> register(
    String username,
    String password,
  ) async {
    final result = await _remote.register(username, password);
    return switch (result) {
      Success(:final value) => _handleAuthSuccess(value.user, value.tokens),
      Err(:final failure) => Err(failure),
    };
  }

  @override
  Future<Result<void>> logout() async {
    
    try {
      final refreshToken = await _local.readRefreshToken();
      if (refreshToken != null) {
        await _remote.logout(refreshToken);
      }
    } catch (e) {
      debugPrint('[AuthRepo] Server logout failed (ignored): $e');
    }
    await _local.clearAll();
    return const Success(null);
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    
    final cached = await _local.getCachedUser();
    if (cached != null) return Success<User>(cached);
    return const Err<User>(AuthFailure('Użytkownik nie jest zalogowany'));
  }

  @override
  Future<Result<AuthTokens>> refreshTokens() async {
    final refreshToken = await _local.readRefreshToken();
    if (refreshToken == null) {
      return const Err(AuthFailure('Brak refresh tokenu'));
    }

    final result = await _remote.refreshTokens(refreshToken);
    return switch (result) {
      Success(:final value) => () async {
          await _local.saveTokens(value);
          return Success<AuthTokens>(value);
        }(),
      Err(:final failure) => Err<AuthTokens>(failure),
    };
  }

  @override
  Future<bool> isAuthenticated() async {
    return _local.hasTokens();
  }

  

  Future<Result<User>> _handleAuthSuccess(
    UserModel user,
    AuthTokensModel tokens,
  ) async {
    
    if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
      return const Err(AuthFailure('Serwer nie zwrócił tokenów autoryzacji'));
    }
    await _local.saveTokens(tokens);
    await _local.cacheUser(user);
    return Success(user);
  }
}
