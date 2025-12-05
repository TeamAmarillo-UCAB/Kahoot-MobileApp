// lib/Motor_Juego_Vivo/infrastructure/datasource/game_socket_datasource_fake.dart

import 'dart:async';

import '../../domain/datasource/game_socket_datasource.dart';

class FakeSocketDatasource implements GameSocketDatasource {
  final _controller = StreamController<dynamic>.broadcast();

  @override
  Future<void> connect({
    required String pin,
    required String role,
    required String playerId,
    required String username,
    required String nickname,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    _controller.add({
      "event": "game_state_update",
      "data": {
        "state": "LOBBY",
        "players": [
          {
            "playerId": playerId,
            "username": username,
            "nickname": nickname,
            "totalPoints": 0,
            "role": role,
          }
        ],
        "quizTitle": "Fake Quiz",
        "quizMediaUrl": null,
        "questionIndex": 0,
        "scoreboard": [],
        "hostId": role == "HOST" ? playerId : "fake-host-id",
      }
    });
  }

  @override
  void emit(String event, dynamic payload) {
    // HOST START GAME → question_started
    if (event == "host_start_game") {
      _controller.add({
        "event": "question_started",
        "data": {
          "questionIndex": 1,
          "currentSlideData": {
            "slideId": "slide-1",
            "questionIndex": 1,
            "questionText": "¿Capital de Francia?",
            "mediaUrl": null,
            "timeLimitSeconds": 15,
            "type": "MULTIPLE_CHOICE",
            "options": [
              {"text": "Madrid", "image": null},
              {"text": "París", "image": null},
              {"text": "Roma", "image": null},
              {"text": "Londres", "image": null},
            ]
          }
        }
      });
    }

    // PLAYER SUBMIT ANSWER → question_results
    if (event == "player_submit_answer") {
      _controller.add({
        "event": "question_results",
        "data": {
          "state": "RESULTS",
          "correctAnswerId": 1,
          "pointsEarned": 900,
          "playerScoreboard": [
            {
              "playerId": payload["playerId"],
              "username": "fakeUser",
              "nickname": "Fake Player",
              "totalPoints": 900,
              "position": 1
            }
          ],
        }
      });
    }

    // HOST NEXT PHASE → game_end
    if (event == "host_next_phase") {
      _controller.add({
        "event": "game_end",
        "data": {
          "state": "END",
          "winnerNickname": "Winner",
          "finalScoreboard": [
            {
              "playerId": "p1",
              "username": "fakeUser",
              "nickname": "Winner",
              "totalPoints": 1200,
              "position": 1
            }
          ],
        }
      });
    }
  }

  @override
  Stream<dynamic> listen() => _controller.stream;

  @override
  void disconnect() {
    _controller.close();
  }
}
