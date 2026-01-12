import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Removed social login buttons for a cleaner register view
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
import '../application/usecases/login_user.dart';
import 'login_page.dart';
import '../../../main.dart';
import 'pages/account_page.dart';
import '../../core/auth_state.dart';

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
  final TextEditingController _fullNameCtrl = TextEditingController();
  String _selectedType = 'student';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _userIdCtrl.dispose();
    _fullNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDatasource = UserDatasourceImpl();
    userDatasource.dio.options.baseUrl = apiBaseUrl.trim();
    // Debug: show configured base URL
    // ignore: avoid_print
    print('UserDatasource baseUrl: ' + userDatasource.dio.options.baseUrl.toString());
    final repository = UserRepositoryImpl(datasource: userDatasource);
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserEditorCubit>(
          create: (_) => UserEditorCubit(
            createUserUseCase: CreateUser(repository),
            updateUserUseCase: UpdateUser(repository),
            loginUserUseCase: LoginUser(repository),
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
        backgroundColor: const Color(0xFF9A5C0A),
        body: Column(
          children: [
            // Encabezado eliminado para diseño limpio
            const SizedBox(height: 0),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
              width: 360,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 1))],
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
                    // Navegar de regreso a AccountPage después de registrar correctamente
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AccountPage()),
                      (route) => route.isFirst,
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const SizedBox(height: 14),
                  const Text(
                    'Registrarse',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Nombre de usuario',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _fullNameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Nombre y Apellido',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        'Ya tienes cuenta? Inicia sesión',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Tipo de usuario', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Checkbox(
                        value: _selectedType == 'student',
                        onChanged: (val) {
                          setState(() => _selectedType = 'student');
                        },
                      ),
                      const Text('Estudiante', style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 16),
                      Checkbox(
                        value: _selectedType == 'teacher',
                        onChanged: (val) {
                          setState(() => _selectedType = 'teacher');
                        },
                      ),
                      const Text('Profesor', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<UserEditorCubit, UserEditorState>(
                    builder: (context, state) {
                      final saving = state.status == UserEditorStatus.saving;
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: GradientButton(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          onTap: saving
                              ? null
                              : () {
                                  final username = _nameCtrl.text.trim();
                                  final email = _emailCtrl.text.trim();
                                  final password = _passwordCtrl.text.trim();
                                  if (username.isEmpty || email.isEmpty || password.isEmpty || _selectedType.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Completa todos los campos.')),
                                    );
                                    return;
                                  }
                                  // Persistir auxiliarmente nombre completo y tipo para createUser
                                  AuthState.fullName.value = _fullNameCtrl.text.trim();
                                  AuthState.userType.value = _selectedType;
                                  final cubit = context.read<UserEditorCubit>();
                                  cubit
                                    ..setName(username)
                                    ..setEmail(email)
                                    ..setPassword(password);
                                  cubit.saveCreate();
                                },
                          child: Text(
                            saving ? 'Guardando...' : 'Crear cuenta',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ), // BlocListener
            ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


