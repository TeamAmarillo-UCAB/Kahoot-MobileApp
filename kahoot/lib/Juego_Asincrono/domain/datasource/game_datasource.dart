import '../entities/attempt.dart';
import '../entities/game_summary.dart';

abstract class GameDatasource {
  /// Llama al endpoint POST /attempts
  Future<Attempt> startAttempt(String kahootId);

  /// Llama al endpoint GET /attempts/{id}
  Future<Attempt> getAttemptStatus(String attemptId);

  /// Llama al endpoint POST /attempts/{id}/answer
  /// Devuelve el JSON crudo (Map) para que el repositorio lo procese
  Future<Map<String, dynamic>> submitAnswer({
    required String attemptId,
    required String slideId,
    required List<int> answerIndex,
    required int timeElapsedSeconds,
    String? textAnswer,
  });

  /// Llama al endpoint GET /attempts/{id}/summary
  Future<GameSummary> getSummary(String attemptId);
}
