abstract class GameEvent {}

class OnStartGame extends GameEvent {
  final String kahootId;
  OnStartGame(this.kahootId);
}

class OnSubmitAnswer extends GameEvent {
  final List<int> answerIndexes;
  final int timeSeconds;
  final String? textAnswer;
  OnSubmitAnswer({
    required this.answerIndexes,
    required this.timeSeconds,
    this.textAnswer,
  });
}

class OnNextQuestion extends GameEvent {}
