import '../../domain/repositories/user_repository.dart';
import '../../../core/result.dart';

class LoginUser {
  final UserRepository repository;
  LoginUser(this.repository);

  Future<Result<void>> call(String email, String password) async {
    return await repository.userLogin(email, password);
  }
}
