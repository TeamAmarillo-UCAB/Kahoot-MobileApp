import '../../common/core/result.dart';
import '../entities/live_session.dart';
import '../entities/live_game_state.dart';

abstract class LiveGameRepository {
  // REST
  Future<Result<LiveSession>> createSession(String kahootId);
  Future<Result<Map<String, dynamic>>> getPinByQR(String qrToken);

  // WebSocket lifecycle
  void connect({
    required String pin,
    required String role,
    required String nickname,
    required String jwt,
  });
  void disconnect();

  // Emitters
  void sendClientReady();
  void joinPlayer(String nickname);
  void hostStartGame();
  void hostNextPhase();
  void submitAnswer({
    required String questionId,
    required List<String> answerIds,
    required int timeElapsedMs,
  });

  // Stream de estado transformado
  Stream<LiveGameState> get gameStateStream;
}
