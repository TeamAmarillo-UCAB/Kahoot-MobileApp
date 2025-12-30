import 'package:flutter/material.dart';
import 'widgets/social_button.dart';
import 'register_page.dart';
import '../../core/widgets/gradient_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    obscureText: true,
                    decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      suffixIcon: Icon(Icons.visibility_off),
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
                  GradientButton(
                    onTap: () {},
                    child: const Text('Iniciar sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    );
  }
}


