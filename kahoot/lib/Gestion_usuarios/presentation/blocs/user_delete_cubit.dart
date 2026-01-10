import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/usecases/delete_user.dart';

enum UserDeleteStatus { idle, deleting, deleted, error }

class UserDeleteState {
  final UserDeleteStatus status;
  final String? errorMessage;
  const UserDeleteState({required this.status, this.errorMessage});
}

class UserDeleteCubit extends Cubit<UserDeleteState> {
  final DeleteUser deleteUser;
  UserDeleteCubit({required this.deleteUser}) : super(const UserDeleteState(status: UserDeleteStatus.idle));

  Future<void> removeById(String id) async {
    emit(const UserDeleteState(status: UserDeleteStatus.deleting));
    final result = await deleteUser.call(id);
    if (result.isSuccessful()) {
      emit(const UserDeleteState(status: UserDeleteStatus.deleted));
    } else {
      emit(UserDeleteState(status: UserDeleteStatus.error, errorMessage: result.getError().toString()));
    }
  }
}
