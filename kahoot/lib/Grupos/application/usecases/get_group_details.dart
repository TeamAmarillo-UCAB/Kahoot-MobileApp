import '../../common/core/result.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/assigned_quiz.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/group_repository.dart';

class GroupFullData {
  final List<GroupMember> members;
  final List<AssignedQuiz> quizzes;
  final List<LeaderboardEntry> leaderboard;

  GroupFullData({
    required this.members,
    required this.quizzes,
    required this.leaderboard,
  });
}

class GetGroupDetails {
  final GroupRepository repository;

  GetGroupDetails(this.repository);

  Future<Result<GroupFullData>> call(String userId, String groupId) async {
    final results = await Future.wait([
      repository.getGroupMembers(userId, groupId),
      repository.getGroupQuizzes(userId, groupId),
      repository.getGroupLeaderboard(userId, groupId),
    ]);

    final membersResult = results[0] as Result<List<GroupMember>>;
    final quizzesResult = results[1] as Result<List<AssignedQuiz>>;
    final leaderboardResult = results[2] as Result<List<LeaderboardEntry>>;

    if (membersResult.isSuccessful() && quizzesResult.isSuccessful()) {
      return Result.success(
        GroupFullData(
          members: membersResult.getValue(),
          quizzes: quizzesResult.getValue(),
          leaderboard: leaderboardResult.isSuccessful()
              ? leaderboardResult.getValue()
              : [],
        ),
      );
    } else {
      String errorMsg;

      if (!membersResult.isSuccessful()) {
        errorMsg = membersResult.getError().toString();
      } else {
        errorMsg = quizzesResult.getError().toString();
      }

      return Result.error(Exception(errorMsg));
    }
  }
}
