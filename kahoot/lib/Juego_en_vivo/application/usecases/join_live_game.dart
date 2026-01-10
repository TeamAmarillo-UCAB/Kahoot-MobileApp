import '../../domain/repositories/live_game_repository.dart';

class JoinLiveGame {
  final LiveGameRepository repository;

  JoinLiveGame(this.repository);

  void call(String nickname) {
    repository.joinPlayer(nickname);
  }
}
