
import '../../domain/repositories/game_repository.dart';

class JoinGameUsecase {
  final GameRepository repo;
  JoinGameUsecase(this.repo);

  Future<void> call(String sessionPin, String nickname) async {
    repo.connectToSession(sessionPin: sessionPin, nickname: nickname);
    repo.emitPlayerJoin(sessionPin, nickname);
  }
}
