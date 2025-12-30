import '../../domain/repositories/user_repository.dart';
import '../../domain/datasource/user_datasource.dart';
import '../../domain/entities/user.dart';
import '../../../core/result.dart';

class UserRepositoryImpl implements UserRepository {
	final UserDatasource datasource;

	UserRepositoryImpl({required this.datasource});

	@override
	Future<Result<void>> createUser(String name, String email, String password, String userType) async {
		try {
			await datasource.createUser(name, email, password, userType);
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
}
