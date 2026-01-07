import '../../domain/repositories/live_game_repository.dart';

class StartLiveGame {
  final LiveGameRepository repository;

  StartLiveGame(this.repository);

  void call() {
    repository.hostStartGame();
  }
}
