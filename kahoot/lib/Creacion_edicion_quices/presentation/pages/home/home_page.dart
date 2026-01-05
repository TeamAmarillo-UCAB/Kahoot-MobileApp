import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Importaciones de otras épicas/módulos
import '../create/create_kahoot_page.dart';
import '../../../../Motor_Juego_Vivo/presentation/game_module_wrapper.dart';

// Importaciones de la Épica 8 (Grupos)
import '../../../../Grupos/infrastructure/repositories/group_repository_impl.dart';
import '../../../../Grupos/infrastructure/datasources/group_datasource_impl.dart';
import '../../../../Grupos/application/usecases/get_user_groups.dart';
import '../../../../Grupos/application/usecases/create_group.dart';
import '../../../../Grupos/application/usecases/join_group.dart';
import '../../../../Grupos/presentation/bloc/group_list/group_list_bloc.dart';
import '../../../../Grupos/presentation/bloc/group_list/group_list_event.dart';
import '../../../../Grupos/presentation/pages/my_groups_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // ID Temporal para pruebas (obtenido de tus ejemplos de API).
  // En producción, esto debería venir de tu AuthBloc o SharedPreferences.
  final String _currentUserId = '397b9a84-f851-417e-91da-fdfc271b1a81';

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
            const Text(
              'Kahoot!',
              style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFEE58),
              foregroundColor: Colors.brown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F),
                  foregroundColor: Colors.brown,
                  elevation: 4,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
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
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 2) {
            // Unirse -> Módulo de Juego
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GameModuleWrapper()),
            );
          } else if (index == 3) {
            // Crear -> Crear Kahoot
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CreateKahootPage()));
          } else if (index == 4) {
            // ✅ BIBLIOTECA -> GRUPOS DE ESTUDIO
            // Aquí envolvemos la navegación con toda la inyección de dependencias necesaria
            _navigateToGroups(context);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: _NavIcon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: _NavIcon(Icons.explore),
            label: 'Descubre',
          ),
          BottomNavigationBarItem(icon: _NavIcon(Icons.group), label: 'Unirse'),
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

  void _navigateToGroups(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          // 1. Instanciar Capa de Infraestructura
          final datasource = GroupDatasourceImpl();
          final repository = GroupRepositoryImpl(datasource: datasource);

          // 2. Instanciar Bloc con los Casos de Uso necesarios
          return BlocProvider(
            create: (context) => GroupListBloc(
              getUserGroups: GetUserGroups(repository),
              createGroup: CreateGroup(repository),
              joinGroup: JoinGroup(repository),
              currentUserId: _currentUserId,
            )..add(LoadGroupsEvent()), // Cargar grupos al iniciar
            child: MyGroupsPage(),
          );
        },
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
      offset: const Offset(0, -4),
      child: Icon(data, size: 24),
    );
  }
}
