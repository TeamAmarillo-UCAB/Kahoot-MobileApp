import '../../common/core/result.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/group_repository.dart';

class GetGroupLeaderboard {
  final GroupRepository repository;

  GetGroupLeaderboard(this.repository);

  Future<Result<List<LeaderboardEntry>>> call(String userId, String groupId) {
    return repository.getGroupLeaderboard(userId, groupId);
  }
}
