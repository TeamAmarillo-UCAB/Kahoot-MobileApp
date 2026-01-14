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
import '../../Creacion_edicion_quices/presentation/pages/home/home_page.dart';
import '../../main.dart';
import '../../core/auth_state.dart';
import '../../config/api_config.dart';
import '../../config/backend_selector_widget.dart';
import 'package:dio/dio.dart';

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
    datasource.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.baseUrl = ApiConfig().baseUrl.trim();
          print("Saliendo petición hacia: ${options.baseUrl}"); // Para depurar
          return handler.next(options);
        },
      ),
    );
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
        backgroundColor: const Color(0xFF9A5C0A),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 360,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: BlocListener<UserEditorCubit, UserEditorState>(
                  listener: (context, state) {
                    if (state.status == UserEditorStatus.error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.errorMessage ?? 'Error al iniciar sesión',
                          ),
                        ),
                      );
                    } else if (state.status == UserEditorStatus.saved) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Inicio de sesión exitoso'),
                        ),
                      );
                      // Marcar sesión iniciada y guardar email/username derivados
                      AuthState.isLoggedIn.value = true;
                      AuthState.email.value = _emailCtrl.text.trim();
                      final derived = _emailCtrl.text.trim().split('@').first;
                      AuthState.username.value = (derived.isNotEmpty
                          ? derived
                          : _emailCtrl.text.trim());
                      // Navega al MainShell con footer y limpia el stack
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainShell()),
                        (route) => false,
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),

                      const SizedBox(height: 14),

                      const SizedBox(height: 14),
                      Row(
                        children: const [
                          Expanded(
                            child: Divider(
                              thickness: 2,
                              color: Color(0xFFFFD54F),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'o',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 2,
                              color: Color(0xFFFFD54F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                          hintText: 'Nombre de usuario',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Request a New Password',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<UserEditorCubit, UserEditorState>(
                        builder: (context, state) {
                          final saving =
                              state.status == UserEditorStatus.saving;
                          return GradientButton(
                            onTap: saving
                                ? null
                                : () {
                                    final userName = _emailCtrl.text.trim();
                                    final password = _passwordCtrl.text.trim();
                                    if (userName.isEmpty || password.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Completa usuario y contraseña.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    final cubit = context
                                        .read<UserEditorCubit>();
                                    cubit
                                      ..setEmail(userName)
                                      ..setPassword(password);
                                    cubit.login();
                                  },
                            child: const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: '. Lee nuestro '),
                            TextSpan(
                              text: 'aviso de privacidad.',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
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
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'New here? Create an account',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(child: BackendSelector()),
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
