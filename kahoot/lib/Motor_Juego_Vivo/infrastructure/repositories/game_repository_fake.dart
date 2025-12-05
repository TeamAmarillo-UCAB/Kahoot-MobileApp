import 'dart:async';

import '../../domain/repositories/game_repository.dart';
import '../../domain/datasource/game_api_datasource.dart';
import '../../domain/datasource/game_socket_datasource.dart';
import '../../domain/entities/game_state.dart';

class FakeGameRepository implements GameRepository {
  final GameApiDatasource api;
  final GameSocketDatasource socket;

  FakeGameRepository({
    required this.api,
    required this.socket,
  });

  @override
  Future<void> createSession({required String kahootId}) {
    return api.createSession(kahootId: kahootId);
  }

  @override
  Future<void> scanQr({required String qrToken}) {
    return api.getSessionByQrToken(qrToken: qrToken);
  }

  @override
  Future<void> joinGame({
    required String pin,
    required String role,
    required String playerId,
    required String username,
    required String nickname,
  }) {
    return socket.connect(
      pin: pin,
      role: role,
      playerId: playerId,
      username: username,
      nickname: nickname,
    );
  }

  @override
  Future<void> hostStartGame() async {
    socket.emit("host_start_game", {});
  }

  @override
  Future<void> hostNextPhase() async {
    socket.emit("host_next_phase", {});
  }

  @override
  Future<void> submitAnswer({
    required String questionId,
    required int answerId,
    required int timeElapsedMs,
  }) async {
    socket.emit("player_submit_answer", {
      "questionId": questionId,
      "answerId": answerId,
      "timeElapsedMs": timeElapsedMs,
    });
  }

  @override
  Stream<GameStateEntity> listenToGameState() {
    return socket.listen().map((event) {
      final data = event["data"];
      return GameStateEntity.fromJson(data);
    });
  }

  @override
  void disconnect() => socket.disconnect();
}
