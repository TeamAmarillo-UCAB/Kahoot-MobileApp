import '../../domain/repositories/game_repository.dart';
import '../../domain/entities/game_summary.dart';
import '../../core/result.dart';

class GetSummary {
  final GameRepository repository;

  GetSummary(this.repository);

  Future<Result<GameSummary>> call(String attemptId) async {
    return await repository.getSummary(attemptId);
  }
}
