import '../../core/result.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/entities/attempt.dart';


class GetAttemptStatus {
  final GameRepository repository;

  GetAttemptStatus(this.repository);

  Future<Result<Attempt>> call(String attemptId) async {
    return await repository.getAttemptStatus(attemptId);
  }
}
