import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/result.dart';
import '../domain/repositories/auth_repository.dart';
import 'auth_infra_providers.dart';
import 'auth_state.dart';


class AuthNotifier extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    return const AuthInitial();
  }

  
  Future<void> init() async {
    final hasTokens = await _repository.isAuthenticated();
    if (!hasTokens) {
      state = const AuthUnauthenticated();
      return;
    }

    state = const AuthLoading();

    
    final refreshResult = await _repository.refreshTokens();

    if (refreshResult case Err(:final failure)) {
      
      if (failure is AuthFailure) {
        debugPrint('[AuthNotifier] Token refresh failed (AuthFailure) -> Logging out');
        await logout();
        return;
      }
      
      debugPrint('[AuthNotifier] Token refresh failed ($failure) -> Proceeding to cached user');
    }

    
    final result = await _repository.getCurrentUser();
    state = switch (result) {
      Success(:final value) => AuthAuthenticated(value),
      Err() => const AuthUnauthenticated(),
    };
  }

  
  Future<void> login(String username, String password) async {
    state = const AuthLoading();
    final result = await _repository.login(username, password);
    state = switch (result) {
      Success(:final value) => AuthAuthenticated(value),
      Err(:final failure) => AuthError(failure.message),
    };
  }

  
  Future<void> register(
    String username,
    String password,
  ) async {
    state = const AuthLoading();
    final result = await _repository.register(username, password);
    state = switch (result) {
      Success(:final value) => AuthAuthenticated(value),
      Err(:final failure) => AuthError(failure.message),
    };
  }

  
  Future<void> logout() async {
    final result = await _repository.logout();
    if (result.isFailure) {
      debugPrint('[AuthNotifier] Logout had errors, clearing state anyway');
    }
    state = const AuthUnauthenticated();
  }

  
  void forceSessionExpired() {
    debugPrint('[AuthNotifier] Session expired — forcing logout');
    state = const AuthUnauthenticated();
  }

  
  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }
}
