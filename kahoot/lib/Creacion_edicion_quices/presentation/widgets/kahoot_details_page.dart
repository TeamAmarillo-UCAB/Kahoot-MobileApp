import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/kahoot/create_kahoot.dart';
import '../../application/usecases/kahoot/update_kahoot.dart';
import '../../infrastructure/datasource/kahoot_datasource_impl.dart';
import '../../infrastructure/repositories/kahoot_repository_impl.dart';
import '../../presentation/blocs/kahoot_editor_cubit.dart';
import '../pages/create/add_question_modal.dart';
import '../../../main.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/kahoot.dart';

import 'package:flutter/material.dart';

class KahootDetailsPage extends StatelessWidget {
  const KahootDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B2E0E),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: const Color(0xFFFFD54F),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Avatar/logo
                  CircleAvatar(
                    backgroundColor: Colors.brown.shade200,
                    radius: 20,
                    child: Icon(Icons.person, color: Colors.brown.shade800),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/kahoot_logo.png',
                    height: 28,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB300),
                      foregroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Text('Actualizar'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.brown),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        // Gato ilustrado
                        Image.asset(
                          'assets/cat_kahoot.png',
                          height: 120,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '¡Hola!',
                          style: TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Unete a un Kahoot o\ncrealo tu mismo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Flecha ilustrada
                        Image.asset(
                          'assets/arrow_down.png',
                          height: 120,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Menú inferior
            Container(
              color: const Color(0xFFFFD54F),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BottomNavItem(icon: Icons.home, label: 'Inicio', selected: true),
                  _BottomNavItem(icon: Icons.search, label: 'Descubre'),
                  _BottomNavItem(icon: Icons.group, label: 'Unirse'),
                  _BottomNavItem(icon: Icons.add_box, label: 'Crear'),
                  _BottomNavItem(icon: Icons.library_books, label: 'Biblioteca'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const _BottomNavItem({required this.icon, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: selected ? Colors.brown : Colors.black54),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: selected ? Colors.brown : Colors.black54,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
