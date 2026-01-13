import '../../common/core/result.dart';
import '../entities/group.dart';
import '../entities/group_detail.dart';
import '../entities/group_member.dart';
import '../entities/group_invitation.dart';
import '../entities/assigned_quiz.dart';
import '../entities/leaderboard_entry.dart';

abstract class GroupRepository {
  Future<Result<List<Group>>> getMyGroups(String userId);
  Future<Result<GroupDetail>> createGroup(
    String userId,
    String name,
    String description,
  );
  Future<Result<GroupDetail>> editGroup(
    String userId,
    String groupId,
    String name,
    String description,
  );
  Future<Result<void>> deleteGroup(String userId, String groupId);

  Future<Result<List<GroupMember>>> getGroupMembers(
    String userId,
    String groupId,
  );
  Future<Result<void>> removeMember(String groupId, String memberId);
  Future<Result<void>> transferAdmin(
    String userId,
    String groupId,
    String newAdminId,
  );

  Future<Result<GroupInvitation>> generateInvitation(
    String userId,
    String groupId,
  );
  Future<Result<Group>> joinGroup(String userId, String token);

  Future<Result<void>> assignQuiz(
    String userId,
    String groupId,
    String quizId,
    DateTime from,
    DateTime until,
  );
  Future<Result<List<AssignedQuiz>>> getGroupQuizzes(
    String userId,
    String groupId,
  );

  Future<Result<List<LeaderboardEntry>>> getGroupLeaderboard(
    String userId,
    String groupId,
  );
  Future<Result<List<LeaderboardEntry>>> getQuizLeaderboard(
    String userId,
    String groupId,
    String quizId,
  );
}
