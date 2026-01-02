import 'package:dio/dio.dart';
import '../../domain/datasource/user_datasource.dart';
import '../../domain/entities/user.dart';

class UserDatasourceImpl implements UserDatasource {
  final Dio dio = Dio();

  @override
  Future<void> createUser(String name, String email, String password, String userType) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
      'userType': userType,
    };
    await dio.post(
      'auth/register',
      data: body,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  @override
  Future<void> updateUser(User user) async {
    final body = {
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'userType': user.userType.toString().split('.').last,
    };
    await dio.put(
      '/profile',
      data: body,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  @override
  Future<void> deleteUser(String userId) async {
    await dio.delete(
      '/users/$userId',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  @override
  Future<User?> getUserById(String userId) async {
    final response = await dio.get(
      '/users/$userId',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    if (response.statusCode == 200) {
      return User.fromJson(response.data);
    } else {
      return null;
    }
  }

  @override
  Future<void> userLogin(String email, String password) async {
    // TODO: Implement with POST to 'auth/login' and body {"email": email, "password": password}
    throw UnimplementedError('userLogin not implemented');
  }

  @override
  Future<void> userLogout() async {
    // TODO: Implement with POST to 'auth/logout'
    throw UnimplementedError('userLogout not implemented');
  }
}
