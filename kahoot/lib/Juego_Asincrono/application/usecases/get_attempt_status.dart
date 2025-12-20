import '../../domain/repositories/game_repository.dart';
import '../../domain/entities/attempt.dart';
import '../../core/result.dart';

class GetAttemptStatus {
  final GameRepository repository;

  GetAttemptStatus(this.repository);

  Future<Result<Attempt>> call(String attemptId) async {
    return await repository.getAttemptStatus(attemptId);
  }
}
