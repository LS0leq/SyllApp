import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String username;
  final String password;
  const LoginParams({required this.username, required this.password});
}

class LoginUseCase extends UseCase<Result<User>, LoginParams> {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  @override
  Future<Result<User>> call(LoginParams params) {
    return _repository.login(params.username, params.password);
  }
}
