import 'package:flutter/material.dart';
import '../../../core/auth_state.dart';
import '../../infrastructure/datasource/user_datasource_impl.dart';
import '../../infrastructure/repositories/user_repository_impl.dart';
import '../../application/usecases/update_user.dart';
import '../../domain/entities/user.dart';
import '../../../main.dart';
import '../../../config/api_config.dart';

class ProfileConfigurationPage extends StatefulWidget {
  const ProfileConfigurationPage({Key? key}) : super(key: key);

  @override
  State<ProfileConfigurationPage> createState() =>
      _ProfileConfigurationPageState();
}

class _ProfileConfigurationPageState extends State<ProfileConfigurationPage> {
  static const Color bgBrown = Color(0xFF3A240C);
  static const Color headerYellow = Color(0xFFF2C147);
  static const Color cardDark = Color(0xFF4A3A23);
  static const Color borderYellow = Color(0xFFA46000);

  late final TextEditingController _usernameCtrl;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: AuthState.username.value ?? '');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBrown,
      appBar: AppBar(
        backgroundColor: bgBrown,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Configuración de perfil',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderYellow, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nombre de usuario',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameCtrl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: headerYellow,
                  ),
                  onPressed: _save,
                  child: const Text(
                    'Guardar',
                    style: TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final newUsername = _usernameCtrl.text.trim();
    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un nombre de usuario')),
      );
      return;
    }
    // Actualiza estado local para que PostLogin refleje el cambio de inmediato
    AuthState.username.value = newUsername;

    // Intentar persistir en backend (si está disponible)
    try {
      final ds = UserDatasourceImpl();
      ds.dio.options.baseUrl = ApiConfig().baseUrl.trim();
      final repo = UserRepositoryImpl(datasource: ds);
      final usecase = UpdateUser(repo);
      final user = User(
        email: AuthState.email.value ?? '',
        name: newUsername,
        password: '',
      );
      await usecase(user);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
    } catch (e) {
      // Si falla, al menos el estado local quedó actualizado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo actualizar en servidor: ' + e.toString()),
        ),
      );
    }
  }
}
