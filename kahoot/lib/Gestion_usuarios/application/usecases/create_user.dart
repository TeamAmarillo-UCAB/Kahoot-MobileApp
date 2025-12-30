import "../../domain/repositories/user_repository.dart";
import "../../../core/result.dart";

class CreateUser {
  final UserRepository repository;

  CreateUser(this.repository);

  Future<Result<void>> call(String name, String email, String password, String userType) async {
    return await repository.createUser(name, email, password, userType);
  }
}