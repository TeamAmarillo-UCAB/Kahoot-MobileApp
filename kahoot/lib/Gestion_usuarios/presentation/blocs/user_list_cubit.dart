import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/user_repository.dart';
import '../../domain/entities/user.dart';
import '../../../core/auth_state.dart';

class UserListState extends Equatable {
  final bool loading;
  final String? email;
  final String? username;
  final String? name;
  final String? error;

  const UserListState({
    required this.loading,
    this.email,
    this.username,
    this.name,
    this.error,
  });

  const UserListState.loading() : this(loading: true);
  const UserListState.error(String msg)
      : this(loading: false, error: msg);
  const UserListState.loaded({String? email, String? username, String? name})
      : this(loading: false, email: email, username: username, name: name);

  @override
  List<Object?> get props => [loading, email, username, name, error];
}

class UserListCubit extends Cubit<UserListState> {
  final UserRepository repository;
  UserListCubit({required this.repository}) : super(const UserListState.loading());

  Future<void> loadProfile() async {
    emit(const UserListState.loading());
    final result = await repository.getUserProfile();
    if (result.isSuccessful()) {
      final User? u = result.getValue();
      // username viene del AuthState poblado en el datasource
      emit(UserListState.loaded(
        email: u?.email,
        username: AuthState.username.value,
        name: u?.name,
      ));
    } else {
      emit(const UserListState.error('No se pudo obtener el perfil.'));
    }
  }
}
