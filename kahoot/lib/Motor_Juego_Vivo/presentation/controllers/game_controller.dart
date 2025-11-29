import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/usecases/join_game_usecase.dart';
import '../../application/usecases/star_game_usecase.dart';
import '../../application/usecases/send_answer_usecase.dart';
import '../../application/usecases/next_phase_usecase.dart';
import '../../application/usecases/listen_game_events_usecase.dart';
import 'game_state.dart';

class GameController extends StateNotifier<GameState> {
  final JoinGameUsecase joinGame;
  final StartGameUsecase startGame;
  final SendAnswerUsecase sendAnswer;
  final NextPhaseUsecase nextPhase;
  final ListenGameEventsUsecase listenEvents;

  DateTime? questionStartTime;

  GameController({
    required this.joinGame,
    required this.startGame,
    required this.sendAnswer,
    required this.nextPhase,
    required this.listenEvents,
  }) : super(GameState());

  Future<void> connect(String pin, String nickname) async {
    state = state.copyWith(loading: true);

    await joinGame(pin, nickname);

    _registerSocketListeners();

    state = state.copyWith(loading: false);
  }

  void _registerSocketListeners() {
    listenEvents(
      onGameState: (payload) {
        final phase = payload["state"];
        state = state.copyWith(
          phase: _parsePhase(phase),
          players: payload["players"] ?? [],
        );
      },
      onQuestionStarted: (payload) {
        questionStartTime = DateTime.now();
        state = state.copyWith(
          phase: GamePhase.question,
          question: payload["currentSlideData"],
        );
      },
      onPlayerAnswerConfirmation: (payload) {
        // puede actualizar un flag de UI
      },
      onQuestionResults: (payload) {
        state = state.copyWith(
          phase: GamePhase.results,
          scoreboard: payload["playerScoreboard"],
        );
      },
      onGameEnd: (payload) {
        state = state.copyWith(
          phase: GamePhase.end,
          scoreboard: payload["finalScoreboard"],
        );
      },
      onError: (payload) {
        print("GAME ERROR: $payload");
      },
    );
  }

  void submitAnswer(String questionId, dynamic answerId) {
    final elapsed = DateTime.now().difference(questionStartTime!).inMilliseconds;
    sendAnswer(
      questionId: questionId,
      answerId: answerId,
      timeElapsedMs: elapsed,
    );
  }

  void hostStart() {
    startGame();
  }

  void goNextPhase() {
    nextPhase();
  }

  GamePhase _parsePhase(String s) {
    switch (s) {
      case "LOBBY":
        return GamePhase.lobby;
      case "QUESTION":
        return GamePhase.question;
      case "RESULTS":
        return GamePhase.results;
      case "END":
        return GamePhase.end;
      default:
        return GamePhase.lobby;
    }
  }
}
