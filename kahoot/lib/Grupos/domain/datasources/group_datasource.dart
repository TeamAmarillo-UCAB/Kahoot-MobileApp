import '../entities/group.dart';
import '../entities/group_detail.dart';
import '../entities/group_member.dart';
import '../entities/group_invitation.dart';
import '../entities/assigned_quiz.dart';
import '../entities/leaderboard_entry.dart';

abstract class GroupDatasource {
  /// Obtiene la lista de grupos del usuario
  Future<List<Group>> getMyGroups(String userId);

  /// Crea un nuevo grupo
  Future<GroupDetail> createGroup(
    String userId,
    String name,
    String description,
  );

  /// Edita un grupo existente
  Future<GroupDetail> editGroup(
    String userId,
    String groupId,
    String name,
    String description,
  );

  /// Elimina un grupo
  Future<void> deleteGroup(String userId, String groupId);

  /// Obtiene los miembros de un grupo
  Future<List<GroupMember>> getGroupMembers(String userId, String groupId);

  /// Elimina un miembro de un grupo
  Future<void> removeMember(String groupId, String memberId);

  /// Transfiere el rol de administrador a otro miembro
  Future<Map<String, dynamic>> transferAdmin(
    String userId,
    String groupId,
    String newAdminId,
  );

  /// Genera un link de invitación
  Future<GroupInvitation> generateInvitation(String userId, String groupId);

  /// Se une a un grupo mediante un token
  Future<Group> joinGroup(String userId, String token);

  /// Asigna un quiz al grupo
  Future<void> assignQuiz(
    String userId,
    String groupId,
    String quizId,
    DateTime from,
    DateTime until,
  );

  /// Obtiene la lista de quizzes asignados
  Future<List<AssignedQuiz>> getGroupQuizzes(String userId, String groupId);

  /// Obtiene el ranking general del grupo
  Future<List<LeaderboardEntry>> getGroupLeaderboard(
    String userId,
    String groupId,
  );

  /// Obtiene el ranking específico de un quiz
  Future<List<LeaderboardEntry>> getQuizLeaderboard(
    String userId,
    String groupId,
    String quizId,
  );
}
