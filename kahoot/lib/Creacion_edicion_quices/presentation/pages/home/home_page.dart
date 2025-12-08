import 'package:flutter/material.dart';
import '../create/create_kahoot_page.dart';
import '../../../../Motor_Juego_Vivo/presentation/game_module_wrapper.dart';



class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD54F),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.account_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Kahoot!', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFEE58),
              foregroundColor: Colors.brown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {},
            child: const Text('Actualizar'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.brown),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¡Que empiecen los juegos!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F),
                  foregroundColor: Colors.brown,
                  elevation: 4,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateKahootPage()),
                  );
                },
                child: const Text('Crear kahoot'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFFD54F),
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.brown.withOpacity(0.7),
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) { // Índice de "Unirse"
            // ✅ Navegación al módulo de juego (Wrapper)
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GameModuleWrapper()),
            );
          } else if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateKahootPage()),
            );
          } else {
            // Otros índices: aún no implementados
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: _NavIcon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(Icons.explore),
            label: 'Descubre',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(Icons.group),
            label: 'Unirse',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(Icons.add_circle_outline),
            label: 'Crear',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(Icons.library_books),
            label: 'Biblioteca',
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData data;
  const _NavIcon(this.data);
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -4), // mover ligeramente hacia arriba
      child: Icon(data, size: 24),
    );
  }
}