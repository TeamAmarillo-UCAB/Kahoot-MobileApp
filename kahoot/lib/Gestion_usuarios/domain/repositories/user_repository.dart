import "../entities/user.dart";
import "../../../core/result.dart";

abstract class UserRepository {
  Future<Result<void>> createUser(String name, String email, String password);
  Future<Result<void>> updateUser(User user);
  Future<Result<void>> deleteUser(String userId);
  Future<Result<User?>> getUserById(String userId);
  Future<Result<User?>> getUserProfile();
  Future<Result<void>> userLogin(String userName, String password);
  Future<Result<void>> userLogout();
}