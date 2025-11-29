import '../../domain/repositories/game_repository.dart';

class ListenGameEventsUsecase {
  final GameRepository repo;

  ListenGameEventsUsecase(this.repo);

  void call({
    required void Function(Map<String, dynamic>) onGameState,
    required void Function(Map<String, dynamic>) onQuestionStarted,
    required void Function(Map<String, dynamic>) onPlayerAnswerConfirmation,
    required void Function(Map<String, dynamic>) onQuestionResults,
    required void Function(Map<String, dynamic>) onGameEnd,
    required void Function(Map<String, dynamic>) onError,
  }) {
    repo.onGameState(onGameState);
    repo.onQuestionStarted(onQuestionStarted);
    repo.onPlayerAnswerConfirmation(onPlayerAnswerConfirmation);
    repo.onQuestionResults(onQuestionResults);
    repo.onGameEnd(onGameEnd);
    repo.onError(onError);
  }
}
