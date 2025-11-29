import '../../domain/repositories/game_repository.dart';

class NextPhaseUsecase {
  final GameRepository repo;

  NextPhaseUsecase(this.repo);

  Future<void> call() async {
    repo.emitHostNextPhase();
  }
}
