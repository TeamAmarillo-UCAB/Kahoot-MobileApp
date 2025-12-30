import "../../domain/repositories/user_repository.dart";
import "../../domain/entities/user.dart";
import "../../../core/result.dart";

class UpdateUser {
  final UserRepository repository;

  UpdateUser(this.repository);

  Future<Result<void>> call(User user) async {
    return await repository.updateUser(user);
  }
}