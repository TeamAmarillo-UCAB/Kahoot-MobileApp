import '../../domain/repositories/game_repository.dart';
import '../../../common/core/result.dart';

class CheckActiveAttempt {
  final GameRepository repository;

  CheckActiveAttempt(this.repository);

  Future<Result<String?>> call(String kahootId) async {
    return await repository.checkActiveAttempt(kahootId);
  }
}
