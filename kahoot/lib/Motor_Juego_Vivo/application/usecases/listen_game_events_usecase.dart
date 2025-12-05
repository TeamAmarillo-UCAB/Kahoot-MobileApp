import '../../domain/repositories/game_repository.dart';
import '../../domain/entities/game_state.dart';

class ListenGameEventsUsecase {
  final GameRepository repository;

  ListenGameEventsUsecase(this.repository);

  Stream<GameStateEntity> call() {
    return repository.listenToGameState();
  }
}
