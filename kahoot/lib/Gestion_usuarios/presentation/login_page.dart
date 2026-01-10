import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/social_button.dart';
import 'register_page.dart';
import '../../core/widgets/gradient_button.dart';
import '../infrastructure/datasource/user_datasource_impl.dart';
import '../infrastructure/repositories/user_repository_impl.dart';
import 'blocs/user_editor_cubit.dart';
import '../application/usecases/create_user.dart';
import '../application/usecases/update_user.dart';
import '../application/usecases/login_user.dart';
import 'pages/post_login_page.dart';
import '../../main.dart';
import '../../core/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final datasource = UserDatasourceImpl();
    datasource.dio.options.baseUrl = apiBaseUrl.trim();
    print('Login datasource baseUrl: ' + datasource.dio.options.baseUrl);
    final repository = UserRepositoryImpl(datasource: datasource);

    return MultiBlocProvider(
      providers: [
        BlocProvider<UserEditorCubit>(
          create: (_) => UserEditorCubit(
            createUserUseCase: CreateUser(repository),
            updateUserUseCase: UpdateUser(repository),
            loginUserUseCase: LoginUser(repository),
          ),
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
                  boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: BlocListener<UserEditorCubit, UserEditorState>(
                  listener: (context, state) {
                    if (state.status == UserEditorStatus.error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage ?? 'Error al iniciar sesión')),
                      );
                    } else if (state.status == UserEditorStatus.saved) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Inicio de sesión exitoso')),
                      );
                      // Marcar sesión iniciada y guardar email/username derivados
                      AuthState.isLoggedIn.value = true;
                      AuthState.email.value = _emailCtrl.text.trim();
                      final derived = _emailCtrl.text.trim().split('@').first;
                      AuthState.username.value = (derived.isNotEmpty ? derived : _emailCtrl.text.trim());
                      // Navega a PostLoginPage y limpia el stack para evitar volver a AccountPage
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const PostLoginPage()),
                        (route) => false,
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
                        'Iniciar sesión',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
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
                      const Text('Email'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Contraseña'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Spacer(),
                          TextButton(
                            onPressed: null,
                            child: const Text(
                              'Restablece tu contraseña',
                              style: TextStyle(decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<UserEditorCubit, UserEditorState>(
                        builder: (context, state) {
                          final saving = state.status == UserEditorStatus.saving;
                          return GradientButton(
                            onTap: saving
                                ? null
                                : () {
                                    final email = _emailCtrl.text.trim();
                                    final password = _passwordCtrl.text.trim();
                                    if (email.isEmpty || password.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Completa email y contraseña.')),
                                      );
                                      return;
                                    }
                                    final cubit = context.read<UserEditorCubit>();
                                    cubit
                                      ..setEmail(email)
                                      ..setPassword(password);
                                    cubit.login();
                                  },
                            child: Text(
                              saving ? 'Ingresando...' : 'Iniciar sesión',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          );
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
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterPage()),
                            );
                          },
                          child: const Text(
                            '¿No tienes cuenta? Regístrate',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
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


