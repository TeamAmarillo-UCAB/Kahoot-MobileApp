import '../../domain/repositories/game_repository.dart';

class StartGameUsecase {
  final GameRepository repo;

  StartGameUsecase(this.repo);

  Future<void> call() async {
    repo.emitHostStartGame();
  }
}
