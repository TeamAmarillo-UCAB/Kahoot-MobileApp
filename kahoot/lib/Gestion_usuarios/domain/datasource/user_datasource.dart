import "../entities/user.dart";

abstract class UserDatasource {
  Future<void> createUser(String email, String name, String password);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String userId);
  Future<User?> getUserById(String userId);
  Future<User?> getUserProfile();
  Future<void> userLogin(String userName, String password);
  Future<void> userLogout();
}