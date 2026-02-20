import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String username;
  final String password;
  const RegisterParams({
    required this.username,
    required this.password,
  });
}

class RegisterUseCase extends UseCase<Result<User>, RegisterParams> {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  @override
  Future<Result<User>> call(RegisterParams params) {
    return _repository.register(params.username, params.password);
  }
}
