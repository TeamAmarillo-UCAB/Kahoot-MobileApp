import 'dart:async';

import '../../domain/datasource/game_socket_datasource.dart';

class FakeSocketDatasource implements GameSocketDatasource {
  final _controller = StreamController<dynamic>.broadcast();

  String? _hostId;

  @override
  Future<void> connect({
    required String pin,
    required String role,
    required String playerId,
    required String username,
    required String nickname,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Si es host, guardamos su ID
    if (role.toUpperCase() == "HOST") {
      _hostId = playerId;
    }

    // Si es player, creamos un host FAKE solo para la simulación
    _hostId ??= "fake-host-id-001";

    _controller.add({
      "event": "game_state_update",
      "data": {
        "hostId": _hostId,
        "state": "LOBBY",
        "players": [
          {
            "playerId": playerId,
            "username": username,
            "nickname": nickname,
            "totalScore": 0,
            "role": role,
          }
        ],
        "quizTitle": "Fake Quiz",
        "quizMediaUrl": null,
        "questionIndex": 0,
        "currentSlideData": null,
      }
    });
  }

  @override
  void emit(String event, dynamic payload) {
    if (event == "host_start_game") {
      _controller.add({
        "event": "question_started",
        "data": {
          "questionIndex": 1,
          "currentSlideData": {
            "slideId": "slide-1",
            "questionText": "¿Capital de Francia?",
            "mediaUrl": null,
            "timeLimitSeconds": 15,
            "type": "MULTIPLE_CHOICE",
            "options": [
              {"text": "Madrid", "image": null},
              {"text": "París", "image": null},
              {"text": "Roma", "image": null},
              {"text": "Londres", "image": null}
            ]
          }
        }
      });
    }

    if (event == "player_submit_answer") {
      _controller.add({
        "event": "question_results",
        "data": {
          "correctAnswerIndex": 1,
          "pointsEarned": 900,
          "playerScoreboard": [
            {
              "playerId": payload["questionId"],
              "username": "fakeUser",
              "nickname": "Fake Player",
              "totalPoints": 900,
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
