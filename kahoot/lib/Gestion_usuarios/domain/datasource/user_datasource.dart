import "../entities/user.dart";

abstract class UserDatasource {
  Future<void> createUser(String name, String email, String password, String userType);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String userId);
  Future<User?> getUserById(String userId);
  Future<void> userLogin(String email, String password);
  Future<void> userLogout();
}