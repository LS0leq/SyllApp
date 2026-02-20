import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

export 'auth_infra_providers.dart'
    show
        sessionExpiredProvider,
        SessionExpiredNotifier,
        secureStorageProvider,
        authLocalDataSourceProvider,
        authInterceptorProvider,
        apiClientProvider,
        authRemoteDataSourceProvider,
        authRepositoryProvider;



final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);



final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider) is AuthAuthenticated;
});
