import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../application/usecases/create_user.dart';
import '../../application/usecases/update_user.dart';
import '../../application/usecases/login_user.dart';
import '../../domain/entities/user.dart';

enum UserEditorStatus { idle, saving, saved, error }

class UserEditorState extends Equatable {
  final String email;
  final String name;
  final String password; // 'student' | 'teacher'
  final UserEditorStatus status;
  final String? errorMessage;

  const UserEditorState({
    required this.email,
    required this.name,
    required this.password,
    required this.status,
    this.errorMessage,
  });

  UserEditorState copyWith({
    String? email,
    String? name,
    String? password,
    UserEditorStatus? status,
    String? errorMessage,
  }) => UserEditorState(
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        status: status ?? this.status,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [email, name, password, status, errorMessage];
}

class UserEditorCubit extends Cubit<UserEditorState> {
  final CreateUser createUserUseCase;
  final UpdateUser updateUserUseCase;
  final LoginUser loginUserUseCase;

  UserEditorCubit({
    required this.createUserUseCase,
    required this.updateUserUseCase,
    required this.loginUserUseCase,
  }) : super(const UserEditorState(
          email: '',
          name: '',
          password: '',
          status: UserEditorStatus.idle,
        ));

    void setEmail(String v) => emit(state.copyWith(email: v));
  void setName(String v) => emit(state.copyWith(name: v));
  void setPassword(String v) => emit(state.copyWith(password: v));

  Future<void> saveCreate() async {
    try {
      emit(state.copyWith(status: UserEditorStatus.saving, errorMessage: null));
      // Validaciones básicas
      if (state.email.trim().isEmpty) {
        throw Exception('El email es requerido.');
      }
      if (state.name.trim().isEmpty) {
        throw Exception('El nombre es requerido.');
      }
      if (state.password.trim().isEmpty) {
        throw Exception('La contraseña es requerida.');
      }
      final result = await createUserUseCase(state.email, state.name, state.password);
      if (result.isSuccessful()) {
        emit(state.copyWith(status: UserEditorStatus.saved));
      } else {
        emit(state.copyWith(status: UserEditorStatus.error, errorMessage: result.getError().toString()));
      }
    } catch (e) {
      emit(state.copyWith(status: UserEditorStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> saveUpdate() async {
    try {
      emit(state.copyWith(status: UserEditorStatus.saving, errorMessage: null));
      if (state.email.trim().isEmpty || state.name.trim().isEmpty || state.password.trim().isEmpty) {
        throw Exception('Todos los campos son requeridos para actualizar.');
      }
      final user = User(
        email: state.email,
        name: state.name,
        password: state.password,
      );
      final result = await updateUserUseCase(user);
      if (result.isSuccessful()) {
        emit(state.copyWith(status: UserEditorStatus.saved));
      } else {
        emit(state.copyWith(status: UserEditorStatus.error, errorMessage: result.getError().toString()));
      }
    } catch (e) {
      emit(state.copyWith(status: UserEditorStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> login() async {
    try {
      emit(state.copyWith(status: UserEditorStatus.saving, errorMessage: null));
      final email = state.email.trim();
      final password = state.password.trim();
      if (email.isEmpty) {
        throw Exception('El email es requerido para iniciar sesión.');
      }
      if (password.isEmpty) {
        throw Exception('La contraseña es requerida para iniciar sesión.');
      }
      final result = await loginUserUseCase(email, password);
      if (result.isSuccessful()) {
        emit(state.copyWith(status: UserEditorStatus.saved));
      } else {
        emit(state.copyWith(status: UserEditorStatus.error, errorMessage: result.getError().toString()));
      }
    } catch (e) {
      emit(state.copyWith(status: UserEditorStatus.error, errorMessage: e.toString()));
    }
  }
}
