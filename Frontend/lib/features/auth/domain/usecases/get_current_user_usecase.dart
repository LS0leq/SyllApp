import '../../../../core/error/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase extends UseCase<Result<User>, NoParams> {
  final AuthRepository _repository;
  GetCurrentUserUseCase(this._repository);

  @override
  Future<Result<User>> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}
