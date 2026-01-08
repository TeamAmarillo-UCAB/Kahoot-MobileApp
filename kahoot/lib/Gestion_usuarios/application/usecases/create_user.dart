import "../../domain/repositories/user_repository.dart";
import "../../../core/result.dart";

class CreateUser {
  final UserRepository repository;

  CreateUser(this.repository);

  Future<Result<void>> call(String email, String name, String password) async {
    return await repository.createUser(email, name, password);
  }
}