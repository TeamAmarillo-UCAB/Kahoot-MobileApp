// lib/Motor_Juego_Vivo/infrastructure/repositories/game_repository_impl.dart

import '../../domain/entities/game_state.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/datasource/game_api_datasource.dart';
import '../../domain/datasource/game_socket_datasource.dart';

import '../mappers/game_state_mapper.dart';

class GameRepositoryImpl implements GameRepository {
  final GameApiDatasource api;
  final GameSocketDatasource socket;

  GameRepositoryImpl({
    required this.api,
    required this.socket,
  });

  /// Estado interno acumulado
  GameStateEntity _currentState = GameStateEntity.initial();

  // ───────────────────────────────────────────────
  // API
  // ───────────────────────────────────────────────

  @override
  Future<void> createSession({required String kahootId}) {
    return api.createSession(kahootId: kahootId);
  }

  @override
  Future<void> scanQr({required String qrToken}) {
    return api.getSessionByQrToken(qrToken: qrToken);
  }

  // ───────────────────────────────────────────────
  // WS: JOIN
  // ───────────────────────────────────────────────
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

  // ───────────────────────────────────────────────
  // WS: Host start game
  // ───────────────────────────────────────────────
  @override
  Future<void> hostStartGame() {
    socket.emit("host_start_game", {});
    return Future.value();
  }

  // ───────────────────────────────────────────────
  // WS: Host next phase
  // ───────────────────────────────────────────────
  @override
  Future<void> hostNextPhase() {
    socket.emit("host_next_phase", {});
    return Future.value();
  }

  // ───────────────────────────────────────────────
  // WS: Player submit answer
  // ───────────────────────────────────────────────
  @override
  Future<void> submitAnswer({
    required String questionId,
    required int answerId,
    required int timeElapsedMs,
  }) {
    socket.emit("player_submit_answer", {
      "playerId": "player-1", // cuando uses JWT lo reemplazas
      "questionId": questionId,
      "answerId": answerId,
      "timeElapsedMs": timeElapsedMs,
    });
    return Future.value();
  }

  // ───────────────────────────────────────────────
  // WS: escuchar TODOS los eventos enviados por el servidor
  // ───────────────────────────────────────────────
  @override
  Stream<GameStateEntity> listenToGameState() {
    return socket.listen().map((raw) {
      final event = raw["event"];
      final data = raw["data"];

      final nextState = GameStateMapper.mapEvent(
        oldState: _currentState,
        event: event,
        data: data is Map ? _forceStringKeyMap(data) : {},
      );

      _currentState = nextState;
      return nextState;
    });
  }

  // Convertir Map<dynamic, dynamic> → Map<String, dynamic>
  Map<String, dynamic> _forceStringKeyMap(Map raw) {
    return raw.map((k, v) => MapEntry(k.toString(), v));
    // es seguro porque Fake y WS real envían strings como keys
  }

  @override
  void disconnect() {
    socket.disconnect();
    _currentState = GameStateEntity.initial();
  }
}
