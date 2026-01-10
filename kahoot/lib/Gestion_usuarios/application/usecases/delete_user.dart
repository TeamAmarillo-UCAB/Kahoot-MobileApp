import "../../domain/repositories/user_repository.dart";
import "../../../../core/result.dart";

class DeleteUser {
  final UserRepository repository;

  DeleteUser(this.repository);

  Future<Result<void>> call(String userId) async {
    return await repository.deleteUser(userId);
  }
}