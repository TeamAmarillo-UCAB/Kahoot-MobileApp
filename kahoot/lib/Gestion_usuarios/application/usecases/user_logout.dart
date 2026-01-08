import "../../domain/repositories/user_repository.dart";
import "../../../core/result.dart";

class UserLogout {
  final UserRepository repository;

  UserLogout(this.repository);

  Future<Result<void>> call() async {
    return await repository.userLogout();
  }
}