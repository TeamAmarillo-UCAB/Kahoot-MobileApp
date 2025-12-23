import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kahoot/Juego_Asincrono/application/usecases/get_attempt_status.dart';
import 'package:kahoot/Juego_Asincrono/application/usecases/get_summary.dart';
import 'package:kahoot/Juego_Asincrono/application/usecases/start_attempt.dart';
import 'package:kahoot/Juego_Asincrono/application/usecases/submit_answer.dart';
import 'package:kahoot/Juego_Asincrono/application/usecases/check_active_attempt.dart';
import 'package:kahoot/Juego_Asincrono/infrastructure/datasource/game_datasource_impl.dart';
import 'package:kahoot/Juego_Asincrono/infrastructure/repositories/game_repository_impl.dart';
import 'package:kahoot/Juego_Asincrono/presentation/blocs/game_bloc.dart';
import 'package:kahoot/Juego_Asincrono/presentation/blocs/game_event.dart';
import '../create/create_kahoot_page.dart';
import '../../../../Motor_Juego_Vivo/presentation/game_module_wrapper.dart';
import '../../../../Juego_Asincrono/presentation/pages/game_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  //KAHOOT DE PRUEBAAAAA
  final String currentKahootId = "3b01e174-6853-4dc0-b846-e6788eee44ad";
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
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GameModuleWrapper()),
            );
          } else if (index == 3) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CreateKahootPage()));
          } else if (index == 4) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (context) {
                    final dio = Dio(
                      BaseOptions(
                        baseUrl: 'https://quizzy-backend-0wh2.onrender.com/api',
                      ),
                    );

                    dio.interceptors.add(
                      InterceptorsWrapper(
                        onRequest: (options, handler) {
                          // PARA CUANDO ESTÉ EL TOKENNNNNNN
                          const String token = "TU_TOKEN_AQUI";

                          if (token.isNotEmpty && token != "TU_TOKEN_AQUI") {
                            options.headers['Authorization'] = 'Bearer $token';
                          }
                          return handler.next(options);
                        },
                        onError: (DioException e, handler) {
                          return handler.next(e);
                        },
                      ),
                    );
                    // ----------------------------

                    final datasource = GameDatasourceImpl(dio: dio);
                    final repository = GameRepositoryImpl(
                      datasource: datasource,
                    );

                    return GameBloc(
                      startAttempt: StartAttempt(repository),
                      submitAnswer: SubmitAnswer(repository),
                      getGameSummary: GetSummary(repository),
                      getAttemptStatus: GetAttemptStatus(repository),
                      checkActiveAttempt: CheckActiveAttempt(repository),
                    )..add(OnStartGame(currentKahootId));
                  },
                  child: GamePage(kahootId: currentKahootId),
                ),
              ),
            );
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
