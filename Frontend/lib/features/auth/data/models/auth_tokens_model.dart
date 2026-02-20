import '../../domain/entities/auth_tokens.dart';


class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: (json['access_token'] ?? json['accessToken']) as String,
      refreshToken: (json['refresh_token'] ?? json['refreshToken']) as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
      };
}
