import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/usecases/join_game_usecase.dart';
import '../../application/usecases/host_start_game_usecase.dart';
import '../../application/usecases/host_next_phase_usecase.dart';
import '../../application/usecases/player_submit_answer_usecase.dart';
import '../../application/usecases/listen_game_events_usecase.dart';
import '../../application/usecases/disconnect_usecase.dart';

import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameUiState> {
  final JoinGameUsecase joinGame;
  final HostStartGameUsecase hostStartGame;
  final HostNextPhaseUsecase hostNextPhase;
  final PlayerSubmitAnswerUsecase submitAnswer;
  final ListenGameEventsUsecase listenEvents;
  final DisconnectUsecase disconnectUsecase;

  StreamSubscription? _wsSubscription;

  GameBloc({
    required this.joinGame,
    required this.hostStartGame,
    required this.hostNextPhase,
    required this.submitAnswer,
    required this.listenEvents,
    required this.disconnectUsecase,
  }) : super(GameUiState.initial()) {
    // REGISTRO DE MANEJADORES
    on<GameEventJoin>(_onJoinGame);
    on<GameEventHostStartGame>(_onHostStartGame);
    on<GameEventHostNextPhase>(_onHostNextPhase);
    on<GameEventSubmitAnswer>(_onSubmitAnswer);
    on<GameEventServerUpdate>(_onServerUpdate);
    on<GameEventDisconnect>(_onDisconnect);
  }

  // ───────────────────────────────
  // JOIN GAME
  // ───────────────────────────────
  Future<void> _onJoinGame(
      GameEventJoin event, Emitter<GameUiState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      await joinGame(
        JoinGameParams(
          pin: event.pin,
          role: event.role,
          playerId: event.playerId,
          username: event.username,
          nickname: event.nickname,
        ),
      );

      // LISTEN WEB SOCKET
      _wsSubscription?.cancel();
      _wsSubscription = listenEvents().listen((newState) {
        add(GameEventServerUpdate(newState));
      });

      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // ───────────────────────────────
  // HOST START GAME
  // ───────────────────────────────
  Future<void> _onHostStartGame(
      GameEventHostStartGame event, Emitter<GameUiState> emit) async {
    await hostStartGame();
  }

  // ───────────────────────────────
  // HOST NEXT PHASE
  // ───────────────────────────────
  Future<void> _onHostNextPhase(
      GameEventHostNextPhase event, Emitter<GameUiState> emit) async {
    await hostNextPhase();
  }

  // ───────────────────────────────
  // PLAYER SUBMIT ANSWER
  // ───────────────────────────────
  Future<void> _onSubmitAnswer(
      GameEventSubmitAnswer event, Emitter<GameUiState> emit) async {
    await submitAnswer(
      SubmitAnswerParams(
        questionId: event.questionId,
        answerId: event.answerId,
        timeElapsedMs: event.timeElapsedMs,
      ),
    );
  }

  // ───────────────────────────────
  // SERVER WS UPDATE
  // ───────────────────────────────
  Future<void> _onServerUpdate(
      GameEventServerUpdate event, Emitter<GameUiState> emit) async {
    emit(state.copyWith(gameState: event.newState));
  }

  // ───────────────────────────────
  // DISCONNECT
  // ───────────────────────────────
  Future<void> _onDisconnect(
      GameEventDisconnect event, Emitter<GameUiState> emit) async {
    _wsSubscription?.cancel();
    disconnectUsecase();
    emit(GameUiState.initial());
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    return super.close();
  }
}
