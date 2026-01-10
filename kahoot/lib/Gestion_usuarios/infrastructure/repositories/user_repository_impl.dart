import '../../domain/repositories/user_repository.dart';
import '../../domain/datasource/user_datasource.dart';
import '../../domain/entities/user.dart';
import '../../../core/result.dart';

class UserRepositoryImpl implements UserRepository {
	final UserDatasource datasource;

	UserRepositoryImpl({required this.datasource});

	@override
	Future<Result<void>> createUser( String email,String name, String password) async {
		try {
			await datasource.createUser(email, name, password);
			return Result.voidSuccess();
		} catch (e, stackTrace) {
			print('Error creating user: ' + e.toString());
			print('Stacktrace: ' + stackTrace.toString());
			return Result.makeError(Exception(e));
		}
	}

	@override
	Future<Result<void>> updateUser(User user) async {
		try {
			await datasource.updateUser(user);
			return Result.voidSuccess();
		} catch (e, stackTrace) {
			print('Error updating user: ' + e.toString());
			print('Stacktrace: ' + stackTrace.toString());
			return Result.makeError(Exception(e));
		}
	}

	@override
	Future<Result<void>> deleteUser(String userId) async {
		try {
			await datasource.deleteUser(userId);
			return Result.voidSuccess();
		} catch (e, stackTrace) {
			print('Error deleting user: ' + e.toString());
			print('Stacktrace: ' + stackTrace.toString());
			return Result.makeError(Exception(e));
		}
	}

  @override
  Future<Result<User?>> getUserById(String userId) async {
    try {
      final user = await datasource.getUserById(userId);
      return Result.success(user);
    } catch (e, stackTrace) {
      print('Error fetching user by ID: ' + e.toString());
      print('Stacktrace: ' + stackTrace.toString());
      return Result.makeError(Exception(e));
    }
  }

	@override
	Future<Result<void>> userLogin(String email, String password) async {
		try {
			await datasource.userLogin(email, password);
			return Result.voidSuccess();
		} catch (e, stackTrace) {
			print('Error logging in: ' + e.toString());
			print('Stacktrace: ' + stackTrace.toString());
			return Result.makeError(Exception(e));
		}
	}

	@override
	Future<Result<void>> userLogout() async {
		try {
			await datasource.userLogout();
			return Result.voidSuccess();
		} catch (e, stackTrace) {
			print('Error logging out: ' + e.toString());
			print('Stacktrace: ' + stackTrace.toString());
			return Result.makeError(Exception(e));
		}
	}
}