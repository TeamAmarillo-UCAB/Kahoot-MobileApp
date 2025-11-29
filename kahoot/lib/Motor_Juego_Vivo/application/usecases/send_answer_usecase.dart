import '../../domain/repositories/game_repository.dart';

class SendAnswerUsecase {
  final GameRepository repo;

  SendAnswerUsecase(this.repo);

  Future<void> call({
    required String questionId,
    required dynamic answerId,
    required int timeElapsedMs,
  }) async {
    repo.emitPlayerSubmitAnswer(
      questionId: questionId,
      answerId: answerId,
      timeElapsedMs: timeElapsedMs,
    );
  }
}
