abstract class GameEvent {}

class OnStartGame extends GameEvent {
  final String kahootId;
  OnStartGame(this.kahootId);
}

class OnSubmitAnswer extends GameEvent {
  final List<int> answerIndexes;
  final int timeSeconds;
  OnSubmitAnswer({required this.answerIndexes, required this.timeSeconds});
}

class OnNextQuestion extends GameEvent {}

class OnFinishGame extends GameEvent {}
