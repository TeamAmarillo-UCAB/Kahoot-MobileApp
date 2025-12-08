import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Importa tus dependencias
import '../application/usecases/join_game_usecase.dart';
import '../application/usecases/host_start_game_usecase.dart';
import '../application/usecases/host_next_phase_usecase.dart';
import '../application/usecases/player_submit_answer_usecase.dart';
import '../application/usecases/listen_game_events_usecase.dart';
import '../application/usecases/disconnect_usecase.dart';

import '../infrastructure/datasource/game_api_datasource_fake.dart';
import '../infrastructure/datasource/game_socket_datasource_fake.dart';
import '../infrastructure/repositories/game_repository_fake.dart';

import 'bloc/game_bloc.dart';

// Importa tus páginas
import 'pages/enter_pin_page.dart';
import 'pages/enter_nickname_page.dart';
import 'pages/lobby_page.dart';
import 'pages/player_question_page.dart';
import 'pages/player_results_page.dart';
import 'pages/podium_page.dart';
import 'pages/host_lobby_page.dart';
import 'pages/host_question_page.dart';
import 'pages/host_results_page.dart';
import 'pages/host_podium_page.dart';

class GameModuleWrapper extends StatefulWidget {
  const GameModuleWrapper({Key? key}) : super(key: key);

  @override
  State<GameModuleWrapper> createState() => _GameModuleWrapperState();
}

class _GameModuleWrapperState extends State<GameModuleWrapper> {
  // Declaramos las instancias "vivas" que persistirán mientras se juegue
  late final FakeApiDatasource _api;
  late final FakeSocketDatasource _socket;
  late final FakeGameRepository _repository;

  @override
  void initState() {
    super.initState();
    // 1. Inicialización de Singletons
    _api = FakeApiDatasource();
    _socket = FakeSocketDatasource();
    _repository = FakeGameRepository(api: _api, socket: _socket);
  }

  @override
  void dispose() {
    // _socket.disconnect(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 2. Creación de Casos de Uso
    final joinUsecase = JoinGameUsecase(_repository);
    final hostStart = HostStartGameUsecase(_repository);
    final hostNext = HostNextPhaseUsecase(_repository);
    final submitAnswer = PlayerSubmitAnswerUsecase(_repository);
    final listenUsecase = ListenGameEventsUsecase(_repository);
    final disconnectUsecase = DisconnectUsecase(_repository);

    // 3. Inyección de Dependencias
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FakeGameRepository>.value(value: _repository),
        RepositoryProvider<FakeSocketDatasource>.value(value: _socket),
      ],
      child: BlocProvider(
        lazy: false, // Forzamos arranque inmediato
        create: (_) => GameBloc(
          joinGame: joinUsecase,
          hostStartGame: hostStart,
          hostNextPhase: hostNext,
          submitAnswer: submitAnswer,
          listenEvents: listenUsecase,
          disconnectUsecase: disconnectUsecase,
        ),
        // 4. Navegación Aislada (Nested Navigator)
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          
          // 🚀 CAMBIOS DE ESTÉTICA KAHOOT! 
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              // Color semilla principal (amarillo/naranja Kahoot!)
              seedColor: const Color(0xFFFFD54F), 
              // Forzamos el brillo oscuro para toda la interfaz
              brightness: Brightness.dark, 
              // Fondo principal muy oscuro
              background: const Color(0xFF222222), 
              // Color de superficie para Cards y Containers
              surface: Colors.grey.shade900, 
            ), 
            useMaterial3: true,
            
            // Estilo global para ElevatedButtons (botones de acción)
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                // Usamos un color oscuro para botones por defecto
                backgroundColor: const Color(0xFF37474F), 
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          // 🚀 FIN DE CAMBIOS DE ESTÉTICA

          initialRoute: '/', 
          routes: {
            '/': (_) => const EnterPinPage(), // Tu punto de entrada
            '/enter_nickname': (_) => const EnterNicknamePage(),
            '/lobby': (_) => const LobbyPage(),
            '/player_question': (_) => const PlayerQuestionPage(),
            '/player_results': (_) => const PlayerResultsPage(),
            '/podium': (_) => const PodiumPage(),
            '/host_lobby': (_) => const HostLobbyPage(),
            '/host_question': (_) => const HostQuestionPage(),
            '/host_results': (_) => const HostResultsPage(),
            '/host_podium': (_) => const HostPodiumPage(),
          },
        ),
      ),
    );
  }
}