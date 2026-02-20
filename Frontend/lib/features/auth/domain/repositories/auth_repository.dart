import '../../../../core/error/result.dart';
import '../entities/auth_tokens.dart';
import '../entities/user.dart';




abstract class AuthRepository {
  
  Future<Result<User>> login(String username, String password);

  
  Future<Result<User>> register(String username, String password);

  
  Future<Result<void>> logout();

  
  Future<Result<User>> getCurrentUser();

  
  Future<Result<AuthTokens>> refreshTokens();

  
  Future<bool> isAuthenticated();
}
