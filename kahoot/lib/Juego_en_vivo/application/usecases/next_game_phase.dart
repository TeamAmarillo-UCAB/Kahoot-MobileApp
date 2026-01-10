import '../../domain/repositories/live_game_repository.dart';

class NextGamePhase {
  final LiveGameRepository repository;

  NextGamePhase(this.repository);

  void call() {
    repository.hostNextPhase();
  }
}
