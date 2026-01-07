import '../../domain/repositories/live_game_repository.dart';

class SubmitLiveAnswer {
  final LiveGameRepository repository;

  SubmitLiveAnswer(this.repository);

  void call({
    required String questionId,
    required List<String> answerIds,
    required int timeElapsedMs,
  }) {
    repository.submitAnswer(
      questionId: questionId,
      answerIds: answerIds,
      timeElapsedMs: timeElapsedMs,
    );
  }
}
