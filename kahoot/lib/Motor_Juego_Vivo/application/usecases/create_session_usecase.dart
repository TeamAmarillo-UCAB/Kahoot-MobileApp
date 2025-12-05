import '../../domain/repositories/game_repository.dart';

class CreateSessionUsecase {
  final GameRepository repository;

  CreateSessionUsecase(this.repository);

  Future<void> call(String kahootId) {
    return repository.createSession(kahootId: kahootId);
  }
}
