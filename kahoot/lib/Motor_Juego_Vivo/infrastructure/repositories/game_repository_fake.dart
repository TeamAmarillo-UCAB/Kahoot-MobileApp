// lib/Motor_Juego_Vivo/infrastructure/repositories/game_repository_fake.dart

import '../../domain/repositories/game_repository.dart';
import '../../domain/datasource/game_api_datasource.dart';
import '../../domain/datasource/game_socket_datasource.dart';
import '../../domain/entities/game_state.dart';
import '../mappers/game_state_mapper.dart';

class FakeGameRepository implements GameRepository {
  final GameApiDatasource api;
  final GameSocketDatasource socket;

  FakeGameRepository({
    required this.api,
    required this.socket,
  });

  /// Estado interno igual que el repo real
  GameStateEntity _currentState = GameStateEntity.initial();

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
  Future<void> hostStartGame() {
    socket.emit("host_start_game", {});
    return Future.value();
  }

  @override
  Future<void> hostNextPhase() {
    socket.emit("host_next_phase", {});
    return Future.value();
  }

  @override
  Future<void> submitAnswer({
    required String questionId,
    required int answerId,
    required int timeElapsedMs,
  }) {
    socket.emit("player_submit_answer", {
      "playerId": "fake-player",
      "questionId": questionId,
      "answerId": answerId,
      "timeElapsedMs": timeElapsedMs,
    });
    return Future.value();
  }

  @override
  Stream<GameStateEntity> listenToGameState() {
    return socket.listen().map((raw) {
      final event = raw["event"];
      final data = raw["data"];

      final next = GameStateMapper.mapEvent(
        oldState: _currentState,
        event: event,
        data: data is Map ? _stringifyMap(data) : {},
      );

      _currentState = next;
      return next;
    });
  }

  Map<String, dynamic> _stringifyMap(Map raw) {
    return raw.map((k, v) => MapEntry(k.toString(), v));
  }

  @override
  void disconnect() {
    socket.disconnect();
    _currentState = GameStateEntity.initial();
  }
}
