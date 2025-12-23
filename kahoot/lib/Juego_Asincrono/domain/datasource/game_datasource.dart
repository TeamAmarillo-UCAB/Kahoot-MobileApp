import '../entities/attempt.dart';
import '../entities/game_summary.dart';

abstract class GameDatasource {
  Future<Attempt> startAttempt(String kahootId);

  Future<Attempt> getAttemptStatus(String attemptId);

  Future<Map<String, dynamic>> submitAnswer({
    required String attemptId,
    required String slideId,
    required List<int> answerIndex,
    required int timeElapsedSeconds,
    String? textAnswer,
  });

  Future<GameSummary> getSummary(String attemptId);

  Future<Map<String, dynamic>> checkActiveAttempt(String kahootId);
}
