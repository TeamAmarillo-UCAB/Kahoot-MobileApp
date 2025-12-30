import "../entities/user.dart";
import "../../../core/result.dart";

abstract class UserRepository {
  Future<Result<void>> createUser(String name, String email, String password, String userType);
  Future<Result<void>> updateUser(User user);
  Future<Result<void>> deleteUser(String userId);
}