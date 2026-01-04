import '../../common/core/result.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/group_repository.dart';

class GetQuizLeaderboard {
  final GroupRepository repository;

  GetQuizLeaderboard(this.repository);

  Future<Result<List<LeaderboardEntry>>> call(
    String userId,
    String groupId,
    String quizId,
  ) {
    return repository.getQuizLeaderboard(userId, groupId, quizId);
  }
}
