import "../../domain/repositories/user_repository.dart";
import "../../domain/entities/user.dart";
import "../../../core/result.dart";

class GetUserById {
  final UserRepository repository;

  GetUserById(this.repository);

  Future<Result<User?>> call(String userId) async {
    return await repository.getUserById(userId);
  }
}