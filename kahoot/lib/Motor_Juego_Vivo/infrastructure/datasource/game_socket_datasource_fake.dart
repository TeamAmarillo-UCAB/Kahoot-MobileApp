import 'dart:async';
import '../../domain/datasource/game_socket_datasource.dart';

class FakeSocketDatasource implements GameSocketDatasource {
  StreamController<dynamic> _controller = StreamController<dynamic>.broadcast();

  // ------------------------------------------------------------
  // CONNECT
  // ------------------------------------------------------------
  @override
  Future<void> connect({
    required String pin,
    required String role,
    required String playerId,
    required String username,
    required String nickname,
  }) async {
    print('[FakeSocket] connect requested pin=$pin role=$role playerId=$playerId');

    // Pequeño delay para permitir que el BLoC se suscriba antes del primer evento
    await Future.delayed(const Duration(milliseconds: 250));

    final wrapper = {
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
    };

    print('[FakeSocket] connect -> emitting initial game_state_update');
    _controller.add(wrapper);
  }

  // ------------------------------------------------------------
  // EMIT
  // ------------------------------------------------------------
  @override
  void emit(String event, dynamic payload) {
    print('[FakeSocket] emit event="$event"');

    if (event == "host_start_game") {
      final wrapper = {
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
      };

      _controller.add(wrapper);
      return;
    }

    if (event == "player_submit_answer") {
      final wrapper = {
        "event": "question_results",
        "data": {
          "state": "RESULTS",
          "correctAnswerId": 1,
          "pointsEarned": 900,
          "playerScoreboard": [
            {
              "playerId": payload["playerId"] ?? "unknown",
              "username": "fakeUser",
              "nickname": "Fake Player",
              "totalPoints": 900,
              "position": 1
            }
          ],
        }
      };

      _controller.add(wrapper);
      return;
    }

    if (event == "host_next_phase") {
      final wrapper = {
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
      };

      _controller.add(wrapper);
      return;
    }
  }

  // ------------------------------------------------------------
  // simulateIncoming (DevTools)
  // ------------------------------------------------------------
  void simulateIncoming(Map<String, dynamic> raw) {
    print('[FakeSocket] simulateIncoming raw event=${raw["event"]}');
    _controller.add(raw);
  }

  // ------------------------------------------------------------
  // LISTEN
  // ------------------------------------------------------------
  @override
  Stream<dynamic> listen() => _controller.stream;

  // ------------------------------------------------------------
  // DISCONNECT (LA PARTE QUE ESTABA MAL)
  // ------------------------------------------------------------
  @override
  void disconnect() {
    print('[FakeSocket] disconnect → resetting stream');

    // Cerrar solo si no está cerrado
    if (!_controller.isClosed) {
      _controller.close();
    }

    // IMPORTANTE: crear un stream NUEVO
    _controller = StreamController<dynamic>.broadcast();

    print('[FakeSocket] new StreamController created');
  }
}
