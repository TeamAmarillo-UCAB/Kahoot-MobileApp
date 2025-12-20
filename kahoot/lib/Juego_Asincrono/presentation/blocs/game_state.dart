import '../../domain/entities/attempt.dart';
import '../../domain/entities/game_summary.dart';

abstract class GameState {}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class ShowingQuestion extends GameState {
  final Attempt attempt;
  ShowingQuestion({required this.attempt});
}

class ShowingFeedback extends GameState {
  final Attempt attempt;
  ShowingFeedback({required this.attempt});
}

class GameFinished extends GameState {
  final GameSummary summary;
  GameFinished({required this.summary});
}

class GameError extends GameState {
  final String message;
  GameError(this.message);
}
