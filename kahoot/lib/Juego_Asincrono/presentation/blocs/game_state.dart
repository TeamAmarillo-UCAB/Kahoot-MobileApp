import '../../domain/entities/attempt.dart';
import '../../domain/entities/game_summary.dart';

abstract class GameState {}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameError extends GameState {
  final String message;
  GameError(this.message);
}

class QuizState extends GameState {
  final Attempt attempt;
  final int currentNumber;
  final int totalQuestions;

  QuizState({
    required this.attempt,
    required this.currentNumber,
    required this.totalQuestions,
  });
}

class ShowingFeedback extends GameState {
  final Attempt attempt;
  final bool wasCorrect;

  ShowingFeedback({required this.attempt, required this.wasCorrect});
}

class GameSummaryState extends GameState {
  final GameSummary summary;
  GameSummaryState(this.summary);
}
