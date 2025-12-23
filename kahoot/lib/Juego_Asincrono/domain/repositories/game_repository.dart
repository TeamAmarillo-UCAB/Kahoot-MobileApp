import '../../../common/core/result.dart';
import '../entities/attempt.dart';
import '../entities/game_summary.dart';

abstract class GameRepository {
  Future<Result<Attempt>> startAttempt(String kahootId);

  Future<Result<Attempt>> getAttemptStatus(String attemptId);

  Future<Result<Attempt>> submitAnswer({
    required String attemptId,
    required String slideId,
    required List<int> answerIndex,
    required int timeElapsed,
    String? textAnswer,
  });

  Future<Result<GameSummary>> getSummary(String attemptId);

  Future<Result<String?>> checkActiveAttempt(String kahootId);
}
