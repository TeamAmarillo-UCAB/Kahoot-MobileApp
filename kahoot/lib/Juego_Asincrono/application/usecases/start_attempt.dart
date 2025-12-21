import '../../domain/repositories/game_repository.dart';
import '../../domain/entities/attempt.dart';
import '../../../common/core/result.dart';

class StartAttempt {
  final GameRepository repository;

  StartAttempt(this.repository);

  Future<Result<Attempt>> call(String kahootId) async {
    return await repository.startAttempt(kahootId);
  }
}
