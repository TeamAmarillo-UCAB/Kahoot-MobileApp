import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/question_slide.dart';
import '../../domain/entities/scoreboard_entry.dart';
import '../../domain/entities/player_info.dart';
import '../../domain/entities/game_state.dart';
import '../bloc/game_bloc.dart';
import '../../infrastructure/datasource/game_socket_datasource_fake.dart';
import '../bloc/game_event.dart';

/// Small developer helper to force game phases locally (no validations).
class DevPhaseControls extends StatelessWidget {
  const DevPhaseControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GameBloc>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => _forcePhase(context, GamePhase.lobby),
          child: const Text('DEV: Lobby'),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => _forcePhase(context, GamePhase.question),
          child: const Text('DEV: Question'),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => _forcePhase(context, GamePhase.results),
          child: const Text('DEV: Results'),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => _forcePhase(context, GamePhase.end),
          child: const Text('DEV: End'),
        ),
      ],
    );
  }

  void _forcePhase(BuildContext context, GamePhase target) {
    final bloc = context.read<GameBloc>();
    final current = bloc.state.gameState;

    // Build a raw event that resembles what the socket would send, then try to
    // inject it into the FakeSocketDatasource (if available). If not, fallback
    // to dispatching a GameEventServerUpdate directly to the bloc.
    Map<String, dynamic> raw = {};

    switch (target) {
      case GamePhase.lobby:
        raw = {
          'event': 'game_state_update',
          'data': {
            'state': 'LOBBY',
            'players': current.players.map((p) => {
                  'playerId': p.playerId,
                  'username': p.username,
                  'nickname': p.nickname,
                  'totalPoints': p.totalScore,
                  'role': p.isHost ? 'HOST' : 'PLAYER',
                }).toList(),
            'quizTitle': current.quizTitle ?? 'Dev Quiz',
            'questionIndex': current.questionIndex,
            'scoreboard': [],
          }
        };
        break;

      case GamePhase.question:
        final idx = current.questionIndex + 1;
        raw = {
          'event': 'question_started',
          'data': {
            'questionIndex': idx,
            'currentSlideData': {
              'slideId': 'slide-$idx',
              'questionIndex': idx,
              'questionText': 'Pregunta dev #$idx',
              'mediaUrl': null,
              'timeLimitSeconds': 15,
              'type': 'MULTIPLE_CHOICE',
              'options': [
                {'text': 'A', 'image': null},
                {'text': 'B', 'image': null},
                {'text': 'C', 'image': null},
                {'text': 'D', 'image': null},
              ]
            }
          }
        };
        break;

      case GamePhase.results:
        raw = {
          'event': 'question_results',
          'data': {
            'state': 'RESULTS',
            'correctAnswerId': 1,
            'pointsEarned': 100,
            'playerScoreboard': current.players.map((p) => {
                  'playerId': p.playerId,
                  'username': p.username,
                  'nickname': p.nickname,
                  'totalPoints': p.totalScore + 100,
                  'position': 1,
                }).toList(),
          }
        };
        break;

      case GamePhase.end:
        raw = {
          'event': 'game_end',
          'data': {
            'state': 'END',
            'winnerNickname': current.players.isNotEmpty ? current.players.first.nickname : 'Dev',
            'finalScoreboard': current.players.map((p) => {
                  'playerId': p.playerId,
                  'username': p.username,
                  'nickname': p.nickname,
                  'totalPoints': p.totalScore + 200,
                  'position': 1,
                }).toList(),
          }
        };
        break;
    }

    // Try to grab the FakeSocketDatasource from RepositoryProvider and inject.
    try {
      final fakeSocket = RepositoryProvider.of<FakeSocketDatasource>(context, listen: false);
      fakeSocket.simulateIncoming(raw);
      return;
    } catch (_) {
      // ignore - fallback to dispatch below
    }

    // Fallback: dispatch mapped state directly to BLoC
    try {
      // For question_started we want to map to GameState similarly to repo
      if (raw['event'] == 'question_started') {
        final idx = raw['data']['questionIndex'] as int? ?? (current.questionIndex + 1);
        final slide = QuestionSlide.fromJson(raw['data']['currentSlideData'] ?? {});
        bloc.add(GameEventServerUpdate(current.copyWith(phase: GamePhase.question, questionIndex: idx, currentSlide: slide)));
      } else if (raw['event'] == 'game_state_update') {
        bloc.add(GameEventServerUpdate(current.copyWith(phase: GamePhase.lobby)));
      } else if (raw['event'] == 'question_results') {
        bloc.add(GameEventServerUpdate(current.copyWith(phase: GamePhase.results)));
      } else if (raw['event'] == 'game_end') {
        bloc.add(GameEventServerUpdate(current.copyWith(phase: GamePhase.end)));
      }
    } catch (e) {
      bloc.add(GameEventServerUpdate(current));
    }
  }
}
