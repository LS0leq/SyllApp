import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';


class AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _cachedUserKey = 'auth_cached_user';

  AuthLocalDataSource(this._storage);

  

  Future<void> saveTokens(AuthTokensModel tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
  }

  Future<String?> readAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> readRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<bool> hasTokens() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  

  Future<void> cacheUser(UserModel user) async {
    await _storage.write(
      key: _cachedUserKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<UserModel?> getCachedUser() async {
    final raw = await _storage.read(key: _cachedUserKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearCachedUser() async {
    await _storage.delete(key: _cachedUserKey);
  }

  

  Future<void> clearAll() async {
    await clearTokens();
    await clearCachedUser();
  }
}
