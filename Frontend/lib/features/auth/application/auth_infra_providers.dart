import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/auth_interceptor.dart';
import '../data/datasources/auth_local_datasource.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/models/auth_tokens_model.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';



class SessionExpiredNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void expire() => state = true;
  void reset() => state = false;
}

final sessionExpiredProvider =
    NotifierProvider<SessionExpiredNotifier, bool>(SessionExpiredNotifier.new);



final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});



final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(ref.watch(secureStorageProvider));
});



final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  final local = ref.watch(authLocalDataSourceProvider);
  return AuthInterceptor(
    readAccessToken: () => local.readAccessToken(),
    readRefreshToken: () => local.readRefreshToken(),
    writeTokens: (access, refresh) async {
      await local.saveTokens(
        AuthTokensModel(accessToken: access, refreshToken: refresh),
      );
    },
    onAuthFailure: () async {
      await local.clearAll();
      ref.read(sessionExpiredProvider.notifier).expire();
    },
  );
});



final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(authInterceptor: ref.watch(authInterceptorProvider));
});



final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider).dio);
});



final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(authLocalDataSourceProvider),
  );
});
