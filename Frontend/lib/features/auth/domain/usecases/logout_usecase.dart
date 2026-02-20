import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase extends UseCase<Result<void>, NoParams> {
  final AuthRepository _repository;
  LogoutUseCase(this._repository);

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.logout();
  }
}
