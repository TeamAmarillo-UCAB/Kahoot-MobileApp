import '../entities/game_state.dart';
abstract class GameRepository {
  // REST
  Future<void> createSession({required String kahootId});
  Future<void> scanQr({required String qrToken});

  // WS connection
  Future<void> joinGame({
    required String pin,
    required String role,
    required String playerId,
    required String username,
    required String nickname,
  });

  Future<void> hostStartGame();
  Future<void> hostNextPhase();

  Future<void> submitAnswer({
    required String questionId,
    required int answerId,
    required int timeElapsedMs,
  });

  Stream<GameStateEntity> listenToGameState();

  void disconnect();
}
