import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../application/usecases/create_user.dart';
import '../../application/usecases/update_user.dart';
import '../../domain/entities/user.dart';

enum UserEditorStatus { idle, saving, saved, error }

class UserEditorState extends Equatable {
  final String name;
  final String email;
  final String password;
  final String userType; // 'student' | 'teacher'
  final UserEditorStatus status;
  final String? errorMessage;

  const UserEditorState({
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
    required this.status,
    this.errorMessage,
  });

  UserEditorState copyWith({
    String? name,
    String? email,
    String? password,
    String? userType,
    UserEditorStatus? status,
    String? errorMessage,
  }) => UserEditorState(
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        userType: userType ?? this.userType,
        status: status ?? this.status,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [name, email, password, userType, status, errorMessage];
}

class UserEditorCubit extends Cubit<UserEditorState> {
  final CreateUser createUserUseCase;
  final UpdateUser updateUserUseCase;

  UserEditorCubit({
    required this.createUserUseCase,
    required this.updateUserUseCase,
  }) : super(const UserEditorState(
          name: '',
          email: '',
          password: '',
          userType: 'student',
          status: UserEditorStatus.idle,
        ));

  void setName(String v) => emit(state.copyWith(name: v));
  void setEmail(String v) => emit(state.copyWith(email: v));
  void setPassword(String v) => emit(state.copyWith(password: v));
  void setUserType(String v) => emit(state.copyWith(userType: v));

  Future<void> saveCreate() async {
    try {
      emit(state.copyWith(status: UserEditorStatus.saving, errorMessage: null));
      // Validaciones básicas
      if (state.name.trim().isEmpty) {
        throw Exception('El nombre es requerido.');
      }
      if (state.email.trim().isEmpty) {
        throw Exception('El email es requerido.');
      }
      if (state.password.trim().isEmpty) {
        throw Exception('La contraseña es requerida.');
      }
      if (state.userType.trim().isEmpty) {
        throw Exception('El tipo de usuario es requerido.');
      }
      final result = await createUserUseCase(state.name, state.email, state.password, state.userType);
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
      if (state.name.trim().isEmpty || state.email.trim().isEmpty || state.password.trim().isEmpty || state.userType.trim().isEmpty) {
        throw Exception('Todos los campos son requeridos para actualizar.');
      }
      final user = User(
        name: state.name,
        email: state.email,
        password: state.password,
        userType: UserTypeX.fromString(state.userType),
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
}
