import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/game_state.dart';
import '../../infrastructure/datasource/game_socket_datasource_fake.dart';
import '../bloc/game_bloc.dart';

/// Dev Tools exclusivamente para entorno FAKE.
class DevPhaseControls extends StatelessWidget {
  const DevPhaseControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<GameBloc>();
    final phase = bloc.state.gameState.phase;
    // Usamos colores claros para el tema oscuro
    final textColor = Colors.white70; 

    return Column(
      children: [
        const SizedBox(height: 12),
        Text("Dev Tools (FAKE)", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _btn(context, "Lobby", GamePhase.lobby),
            const SizedBox(width: 8),
            _btn(context, "Question", GamePhase.question),
            const SizedBox(width: 8),
            _btn(context, "Results", GamePhase.results),
            const SizedBox(width: 8),
            _btn(context, "End", GamePhase.end),
          ],
        ),
        Text("Actual: ${phase.toString().split('.').last}", style: TextStyle(color: textColor)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _btn(BuildContext context, String label, GamePhase phase) {
    return TextButton(
      // Usamos un color de texto más visible para el botón
      style: TextButton.styleFrom(foregroundColor: Colors.lightBlueAccent), 
      onPressed: () => _forcePhase(context, phase),
      child: Text("DEV: $label"),
    );
  }

  /// Fuerza una fase enviando RAW events al FakeSocketDatasource.
  void _forcePhase(BuildContext context, GamePhase target) {
    final bloc = context.read<GameBloc>();
    final state = bloc.state.gameState;

    // Asegúrate de que FakeSocketDatasource esté accesible
    try {
      final fakeSocket = RepositoryProvider.of<FakeSocketDatasource>(context, listen: false);

      debugPrint("[DevTools] Force → $target");

      final raw = _buildRawEvent(state, target);
      debugPrint("[DevTools] simulateIncoming: $raw");

      fakeSocket.simulateIncoming(raw);
    } catch (e) {
      // Manejo de error si FakeSocketDatasource no está en el árbol
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: FakeSocketDatasource no encontrado en el árbol de widgets.', style: TextStyle(color: Colors.white))),
      );
    }
  }

  /// Crea eventos RAW idénticos a los que emite el backend real. (Sin cambios funcionales)
  Map<String, dynamic> _buildRawEvent(GameStateEntity s, GamePhase target) {
    // ... Lógica de construcción de RAW Eventos (sin cambios)
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