
abstract class GameRepository {
  // HTTP
  Future<Map<String, dynamic>> createSession(String kahootId);
  Future<Map<String, dynamic>> getSessionByQrToken(String qrToken);

  // WebSocket control
  void connectToSession({required String sessionPin, required String nickname});
  void disconnect();

  // Emit events
  void emitPlayerJoin(String sessionPin, String nickname);
  void emitHostStartGame();
  void emitPlayerSubmitAnswer({
    required String questionId,
    required dynamic answerId,
    required int timeElapsedMs,
  });
  void emitHostNextPhase();

  // Streams / callbacks
  void onGameState(void Function(Map<String, dynamic>) callback);
  void onQuestionStarted(void Function(Map<String, dynamic>) callback);
  void onQuestionResults(void Function(Map<String, dynamic>) callback);
  void onPlayerAnswerConfirmation(void Function(Map<String, dynamic>) callback);
  void onGameEnd(void Function(Map<String, dynamic>) callback);
  void onError(void Function(Map<String, dynamic>) callback);
}
