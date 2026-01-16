import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/auth_state.dart';
import '../../../core/widgets/gradient_button.dart';
import '../blocs/user_list_cubit.dart';
import '../blocs/user_editor_cubit.dart';
import '../../application/usecases/create_user.dart';
import '../../application/usecases/update_user.dart';
import '../../application/usecases/login_user.dart';
import '../../infrastructure/repositories/user_repository_impl.dart';
import '../../infrastructure/datasource/user_datasource_impl.dart';
import '../../../main.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({Key? key}) : super(key: key);

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _usernameCtrl = TextEditingController(text: AuthState.username.value ?? '');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Paleta consistente con la app
    // Referencias de color mantenidas para consistencia (no usadas directamente aquí)
    const Color cardDark = Color(0xFF4A3A23);
    const Color borderYellow = Color(0xFFA46000);

    return MultiBlocProvider(providers: [
      BlocProvider<UserListCubit>(
        create: (_) {
          final ds = UserDatasourceImpl();
          ds.dio.options.baseUrl = apiBaseUrl.trim();
          print('UpdateProfile datasource baseUrl: ' + ds.dio.options.baseUrl);
          return UserListCubit(
            repository: UserRepositoryImpl(datasource: ds),
          )..loadProfile();
        },
      ),
      BlocProvider<UserEditorCubit>(
        create: (_) {
          final ds = UserDatasourceImpl();
          ds.dio.options.baseUrl = apiBaseUrl.trim();
          final repo = UserRepositoryImpl(datasource: ds);
          return UserEditorCubit(
            createUserUseCase: CreateUser(repo),
            updateUserUseCase: UpdateUser(repo),
            loginUserUseCase: LoginUser(repo),
          );
        },
      ),
    ],
      child: Material(
      color: Colors.transparent,
      child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderYellow, width: 1),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6)),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: BlocListener<UserListCubit, UserListState>(
              listener: (context, state) {
                if (!state.loading && state.error == null) {
                  if (state.email != null) _emailCtrl.text = state.email!;
                  if (state.username != null) _usernameCtrl.text = state.username!;
                }
              },
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4),
                const Text(
                  'Edita tu perfil',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 12),
                _Field(label: 'Email', controller: _emailCtrl, hint: 'Escribe tu email'),
                const SizedBox(height: 12),
                _Field(label: 'Nombre de usuario', controller: _usernameCtrl, hint: 'Tu usuario'),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _GhostButton(
                        label: 'Cancelar',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Builder(
                        builder: (ctx) => GradientButton(
                          onTap: () => _saveWith(ctx),
                          child: const Center(
                            child: Text(
                              'Guardar',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),
          ),
        ),
      ),
      ),
    ));
  }
  void _saveWith(BuildContext innerCtx) async {
    final email = _emailCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    if (username.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos.')),
      );
      return;
    }
    await innerCtx.read<UserEditorCubit>().updateUser(username, email);
    final state = innerCtx.read<UserEditorCubit>().state;
    if (state.status == UserEditorStatus.saved) {
      AuthState.username.value = username;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado.')),
      );
      Navigator.of(context).pop();
    } else if (state.status == UserEditorStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Error al actualizar.')),
      );
    }
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  const _Field({required this.label, required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    const Color inputBg = Color(0xFF3A240C); // bgBrown
    const Color inputBorder = Color(0xFFA46000); // borderYellow
    const Color hintColor = Color(0xFFD9B36F); // text gold

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputBg,
            hintText: hint,
            hintStyle: const TextStyle(color: hintColor),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: inputBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white70, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// Usamos GradientButton para Guardar, eliminando el botón sólido

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GhostButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color border = Color(0xFFA46000); // borderYellow
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        alignment: Alignment.center,
        child: const Text('Cancelar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
