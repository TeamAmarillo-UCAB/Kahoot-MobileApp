import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/usecases/get_user_by_id.dart';
import '../../domain/entities/user.dart';

class UserDetailState extends Equatable {
  final bool loading;
  final User? user;
  final String? error;

  const UserDetailState._({required this.loading, this.user, this.error});

  const UserDetailState.loading() : this._(loading: true);
  const UserDetailState.loaded(User? u) : this._(loading: false, user: u);
  const UserDetailState.error(String err) : this._(loading: false, error: err);

  @override
  List<Object?> get props => [loading, user, error];
}

class UserDetailCubit extends Cubit<UserDetailState> {
  final GetUserById getUserById;

  UserDetailCubit({required this.getUserById}) : super(const UserDetailState.loading());

  Future<void> loadById(String id) async {
    emit(const UserDetailState.loading());
    final result = await getUserById.call(id);
    if (result.isSuccessful()) {
      emit(UserDetailState.loaded(result.getValue()));
    } else {
      emit(const UserDetailState.error('No se pudo obtener el usuario. Intenta más tarde.'));
    }
  }
}
