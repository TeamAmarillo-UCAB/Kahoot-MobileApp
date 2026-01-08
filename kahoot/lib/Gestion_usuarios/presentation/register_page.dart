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
  bool _obscurePassword = true;

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
        backgroundColor: const Color(0xFF3A240C),
        body: Column(
          children: [
            Container(
              color: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Volver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text('Iniciar sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
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
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  const SizedBox(height: 8),
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
                  const Text('Contraseña'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  const Text('Tipo de usuario'),
                  const SizedBox(height: 6),
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
                                      ..setPassword(password);                                    cubit.saveCreate();
                                  },
                            child: Text(
                              saving ? 'Guardando...' : 'Continuar',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
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


