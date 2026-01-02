import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/social_button.dart';
import '../../core/widgets/gradient_button.dart';
import '../infrastructure/repositories/user_repository_impl.dart';
import '../infrastructure/datasource/user_datasource_impl.dart';
import 'blocs/user_editor_cubit.dart';
import 'blocs/user_detail_cubit.dart';
import 'blocs/user_delete_cubit.dart';
import '../application/usecases/create_user.dart';
import '../application/usecases/update_user.dart';
import '../application/usecases/get_user_by_id.dart';
import '../application/usecases/delete_user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _userIdCtrl = TextEditingController();
  String _selectedType = 'student';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _userIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = UserRepositoryImpl(datasource: UserDatasourceImpl());
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserEditorCubit>(
          create: (_) => UserEditorCubit(
            createUserUseCase: CreateUser(repository),
            updateUserUseCase: UpdateUser(repository),
          ),
        ),
        BlocProvider<UserDetailCubit>(
          create: (_) => UserDetailCubit(getUserById: GetUserById(repository)),
        ),
        BlocProvider<UserDeleteCubit>(
          create: (_) => UserDeleteCubit(deleteUser: DeleteUser(repository)),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF3A240C),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
              width: 360,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF2C147),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: BlocListener<UserEditorCubit, UserEditorState>(
                listener: (context, state) {
                  if (state.status == UserEditorStatus.error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage ?? 'Ocurrió un error')),
                    );
                  } else if (state.status == UserEditorStatus.saved) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usuario registrado/actualizado exitosamente')),
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                    children: [
                      GradientButton(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Text('Volver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Registrarse',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SocialButton(icon: Icons.g_mobiledata, label: 'Google'),
                      SocialButton(icon: Icons.grid_view, label: 'Microsoft'),
                      SocialButton(icon: Icons.apple, label: 'Apple'),
                      SocialButton(icon: Icons.school, label: 'Clever'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GradientButton(
                    onTap: () {},
                    child: const Text('Continuar con el email del trabajo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: const [
                      Expanded(child: Divider(thickness: 2, color: Color(0xFFFFD54F))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('o', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Divider(thickness: 2, color: Color(0xFFFFD54F))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Nombre de usuario'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Email'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Contraseña'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      suffixIcon: const Icon(Icons.visibility_off),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Tipo de usuario'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: const [
                      DropdownMenuItem(value: 'student', child: Text('Estudiante')),
                      DropdownMenuItem(value: 'teacher', child: Text('Profesor')),
                    ],
                    onChanged: (v) => setState(() => _selectedType = v ?? 'student'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: null),
                      const Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'Quiero recibir informacion, ofertas, recomendaciones y actualizaciones de kahoot! y ',
                            children: [
                              TextSpan(
                                text: 'Otras empresas de kahoot!',
                                style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<UserEditorCubit, UserEditorState>(
                    builder: (context, state) {
                      final saving = state.status == UserEditorStatus.saving;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GradientButton(
                            onTap: saving
                                ? null
                                : () {
                                    final name = _nameCtrl.text.trim();
                                    final email = _emailCtrl.text.trim();
                                    final password = _passwordCtrl.text.trim();
                                    if (name.isEmpty || email.isEmpty || password.isEmpty || _selectedType.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Completa todos los campos.')),
                                      );
                                      return;
                                    }
                                    final cubit = context.read<UserEditorCubit>();
                                    cubit
                                      ..setName(name)
                                      ..setEmail(email)
                                      ..setPassword(password)
                                      ..setUserType(_selectedType);
                                    cubit.saveCreate();
                                  },
                            child: Text(
                              saving ? 'Guardando...' : 'Continuar',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GradientButton(
                            onTap: saving
                                ? null
                                : () {
                                    final name = _nameCtrl.text.trim();
                                    final email = _emailCtrl.text.trim();
                                    final password = _passwordCtrl.text.trim();
                                    if (name.isEmpty || email.isEmpty || password.isEmpty || _selectedType.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Completa todos los campos para actualizar.')),
                                      );
                                      return;
                                    }
                                    final cubit = context.read<UserEditorCubit>();
                                    cubit
                                      ..setName(name)
                                      ..setEmail(email)
                                      ..setPassword(password)
                                      ..setUserType(_selectedType);
                                    cubit.saveUpdate();
                                  },
                            child: const Text('Actualizar usuario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text('ID de usuario (para consultar/eliminar)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _userIdCtrl,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          onTap: () {
                            final id = _userIdCtrl.text.trim();
                            if (id.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ingresa el ID de usuario.')),
                              );
                              return;
                            }
                            context.read<UserDetailCubit>().loadById(id);
                          },
                          child: const Text('Obtener usuario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GradientButton(
                          onTap: () {
                            final id = _userIdCtrl.text.trim();
                            if (id.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ingresa el ID de usuario.')),
                              );
                              return;
                            }
                            context.read<UserDeleteCubit>().removeById(id);
                          },
                          child: const Text('Eliminar usuario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<UserDetailCubit, UserDetailState>(
                    builder: (context, state) {
                      if (state.loading) {
                        return const Text('Cargando usuario...');
                      }
                      if (state.error != null) {
                        return Text(state.error!, style: const TextStyle(color: Colors.red));
                      }
                      final u = state.user;
                      if (u == null) {
                        return const Text('Usuario no encontrado.');
                      }
                      return Text('Usuario: ${u.name} | Email: ${u.email} | Tipo: ${u.userType.toString().split('.').last}');
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text.rich(
                    TextSpan(
                      text: 'Al registrarte, acepta nuestros ',
                      children: [
                        TextSpan(
                          text: 'Terminos y condiciones',
                          style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '. Lee nuestro '),
                        TextSpan(
                          text: 'aviso de privacidad.',
                          style: TextStyle(decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);
  }
}


