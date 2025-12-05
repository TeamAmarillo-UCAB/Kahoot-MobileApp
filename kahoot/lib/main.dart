import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'Motor_Juego_Vivo/presentation/bloc/game_bloc.dart';
import 'Motor_Juego_Vivo/application/usecases/join_game_usecase.dart';
import 'Motor_Juego_Vivo/application/usecases/host_start_game_usecase.dart';
import 'Motor_Juego_Vivo/application/usecases/host_next_phase_usecase.dart';
import 'Motor_Juego_Vivo/application/usecases/player_submit_answer_usecase.dart';
import 'Motor_Juego_Vivo/application/usecases/listen_game_events_usecase.dart';
import 'Motor_Juego_Vivo/application/usecases/disconnect_usecase.dart';

import 'Motor_Juego_Vivo/infrastructure/datasource/game_api_datasource_fake.dart';
import 'Motor_Juego_Vivo/infrastructure/datasource/game_socket_datasource_fake.dart';
import 'Motor_Juego_Vivo/infrastructure/repositories/game_repository_fake.dart';

import 'Motor_Juego_Vivo/presentation/pages/enter_pin_page.dart';
import 'Motor_Juego_Vivo/presentation/pages/enter_nickname_page.dart';
import 'Motor_Juego_Vivo/presentation/pages/lobby_page.dart';
import 'Motor_Juego_Vivo/presentation/pages/player_question_page.dart';
import 'Motor_Juego_Vivo/presentation/pages/player_results_page.dart';
import 'Motor_Juego_Vivo/presentation/pages/podium_page.dart';
import 'Motor_Juego_Vivo/presentation/pages/host_lobby_page.dart';
import 'Motor_Juego_Vivo/presentation/pages/host_question_page.dart';
import 'Motor_Juego_Vivo/presentation/pages/host_results_page.dart';
import 'Motor_Juego_Vivo/presentation/pages/host_podium_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inyectar implementaciones fake (para pruebas sin backend)
    final api = FakeApiDatasource();
    final socket = FakeSocketDatasource();
    final repository = FakeGameRepository(api: api, socket: socket);

    // Usecases
    final joinUsecase = JoinGameUsecase(repository);
    final hostStart = HostStartGameUsecase(repository);
    final hostNext = HostNextPhaseUsecase(repository);
    final submitAnswer = PlayerSubmitAnswerUsecase(repository);
    final listenUsecase = ListenGameEventsUsecase(repository);
    final disconnectUsecase = DisconnectUsecase(repository);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: repository),
        RepositoryProvider.value(value: socket),
      ],
      child: BlocProvider(
        create: (_) => GameBloc(
          joinGame: joinUsecase,
          hostStartGame: hostStart,
          hostNextPhase: hostNext,
          submitAnswer: submitAnswer,
          listenEvents: listenUsecase,
          disconnectUsecase: disconnectUsecase,
        ),
        child: MaterialApp(
        title: 'Kahoot - Demo',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber)),
        initialRoute: '/',
        routes: {
          '/': (_) => const EnterPinPage(),
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
