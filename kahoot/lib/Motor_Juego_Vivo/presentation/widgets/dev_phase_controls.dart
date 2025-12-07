// lib/Motor_Juego_Vivo/presentation/widgets/dev_phase_controls.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/game_state.dart';
import '../../infrastructure/datasource/game_socket_datasource_fake.dart';
import '../bloc/game_bloc.dart';

/// Dev Tools exclusivamente para entorno FAKE.
/// - Siempre usa FakeSocketDatasource.simulateIncoming()
/// - Nunca toca el BLoC directamente
/// - Nunca llama a repositorio real
/// - Genera RAW events idénticos a los del backend
class DevPhaseControls extends StatelessWidget {
  const DevPhaseControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<GameBloc>();
    final phase = bloc.state.gameState.phase;

    return Column(
      children: [
        const SizedBox(height: 12),
        Text("Dev Tools (FAKE)", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _btn(context, "Lobby", GamePhase.lobby),
            SizedBox(width: 8),
            _btn(context, "Question", GamePhase.question),
            SizedBox(width: 8),
            _btn(context, "Results", GamePhase.results),
            SizedBox(width: 8),
            _btn(context, "End", GamePhase.end),
          ],
        ),
        Text("Actual: ${phase.toString().split('.').last}"),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _btn(BuildContext context, String label, GamePhase phase) {
    return TextButton(
      onPressed: () => _forcePhase(context, phase),
      child: Text("DEV: $label"),
    );
  }

  /// Fuerza una fase enviando RAW events al FakeSocketDatasource.
  void _forcePhase(BuildContext context, GamePhase target) {
    final bloc = context.read<GameBloc>();
    final state = bloc.state.gameState;

    final fakeSocket = RepositoryProvider.of<FakeSocketDatasource>(context, listen: false);

    print("[DevTools] Force → $target");

    final raw = _buildRawEvent(state, target);
    print("[DevTools] simulateIncoming: $raw");

    fakeSocket.simulateIncoming(raw);
  }

  /// Crea eventos RAW idénticos a los que emite el backend real.
  Map<String, dynamic> _buildRawEvent(GameStateEntity s, GamePhase target) {
    switch (target) {
      case GamePhase.lobby:
        return {
          "event": "game_state_update",
          "data": {
            "state": "LOBBY",
            "players": s.players.map((p) => {
                  "playerId": p.playerId,
                  "username": p.username,
                  "nickname": p.nickname,
                  "totalPoints": p.totalScore,
                  "role": p.isHost ? "HOST" : "PLAYER",
                }).toList(),
            "quizTitle": s.quizTitle ?? "Dev Quiz",
            "quizMediaUrl": null,
            "questionIndex": 0,
            "scoreboard": [],
          }
        };

      case GamePhase.question:
        final idx = s.questionIndex + 1;
        return {
          "event": "question_started",
          "data": {
            "questionIndex": idx,
            "currentSlideData": {
              "slideId": "dev-$idx",
              "questionIndex": idx,
              "questionText": "Pregunta DEV #$idx",
              "mediaUrl": null,
              "timeLimitSeconds": 15,
              "type": "MULTIPLE_CHOICE",
              "options": [
                {"text": "A", "image": null},
                {"text": "B", "image": null},
                {"text": "C", "image": null},
                {"text": "D", "image": null},
              ],
            }
          }
        };

      case GamePhase.results:
        return {
          "event": "question_results",
          "data": {
            "state": "RESULTS",
            "correctAnswerId": 1,
            "pointsEarned": 100,
            "playerScoreboard": s.players.map((p) => {
                  "playerId": p.playerId,
                  "username": p.username,
                  "nickname": p.nickname,
                  "totalPoints": p.totalScore + 100,
                  "position": 1,
                }).toList(),
          }
        };

      case GamePhase.end:
        return {
          "event": "game_end",
          "data": {
            "state": "END",
            "winnerNickname": s.players.isNotEmpty ? s.players.first.nickname : "Dev",
            "finalScoreboard": s.players.map((p) => {
                  "playerId": p.playerId,
                  "username": p.username,
                  "nickname": p.nickname,
                  "totalPoints": p.totalScore + 200,
                  "position": 1,
                }).toList(),
          }
        };
    }
  }
}
