import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahoot/Motor_Juego_Vivo/presentation/controllers/game_state.dart';

import '../../domain/repositories/game_repository.dart';
import '../../infrastructure/repositories/game_repository_impl.dart';
import '../../infrastructure/datasource/game_api_datasource.dart';
import '../../infrastructure/datasource/game_socket_datasource.dart';

import '../../application/usecases/join_game_usecase.dart';
import '../../application/usecases/star_game_usecase.dart';
import '../../application/usecases/send_answer_usecase.dart';
import '../../application/usecases/next_phase_usecase.dart';
import '../../application/usecases/listen_game_events_usecase.dart';

import 'game_controller.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final api = GameApiDatasource(Dio());
  final socket = GameSocketDatasource();
  return GameRepositoryImpl(api: api, socket: socket);
});

final gameControllerProvider =
    StateNotifierProvider<GameController, GameState>((ref) {
  final repo = ref.read(gameRepositoryProvider);

  return GameController(
    joinGame: JoinGameUsecase(repo),
    startGame: StartGameUsecase(repo),
    sendAnswer: SendAnswerUsecase(repo),
    nextPhase: NextPhaseUsecase(repo),
    listenEvents: ListenGameEventsUsecase(repo),
  );
});
