import '../../domain/repositories/live_game_repository.dart';
import '../../domain/entities/live_session.dart';
import '../../common/core/result.dart';

class CreateLiveSession {
  final LiveGameRepository repository;

  CreateLiveSession(this.repository);

  Future<Result<LiveSession>> call(String kahootId) async {
    return await repository.createSession(kahootId);
  }
}
