import '../../domain/repositories/game_repository.dart';
import '../../domain/entities/attempt.dart';
import '../../core/result.dart';

class SubmitAnswer {
  final GameRepository repository;

  SubmitAnswer(this.repository);

  Future<Result<Attempt>> call({
    required String attemptId,
    required String slideId,
    required List<int> answerIndex,
    required int timeElapsed,
    String? textAnswer,
  }) async {
    return await repository.submitAnswer(
      attemptId: attemptId,
      slideId: slideId,
      answerIndex: answerIndex,
      timeElapsed: timeElapsed,
      textAnswer: textAnswer,
    );
  }
}
