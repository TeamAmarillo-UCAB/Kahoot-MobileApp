import '../../common/core/result.dart';
import '../../common/core/failure.dart';
import '../../domain/datasources/group_datasource.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_detail.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/group_invitation.dart';
import '../../domain/entities/assigned_quiz.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupDatasource datasource;

  GroupRepositoryImpl({required this.datasource});

  @override
  Future<Result<List<Group>>> getMyGroups(String userId) async {
    try {
      final result = await datasource.getMyGroups(userId);
      return Result.success(result);
    } catch (e) {
      return Result.error(ServerFailure("Error al obtener grupos: $e"));
    }
  }

  @override
  Future<Result<GroupDetail>> createGroup(
    String userId,
    String name,
    String description,
  ) async {
    try {
      final result = await datasource.createGroup(userId, name, description);
      return Result.success(result);
    } catch (e) {
      return Result.error(ServerFailure("Error al crear grupo: $e"));
    }
  }

  @override
  Future<Result<GroupDetail>> editGroup(
    String userId,
    String groupId,
    String name,
    String description,
  ) async {
    try {
      final result = await datasource.editGroup(
        userId,
        groupId,
        name,
        description,
      );
      return Result.success(result);
    } catch (e) {
      return Result.error(ServerFailure("Error al editar grupo: $e"));
    }
  }

  @override
  Future<Result<void>> deleteGroup(String userId, String groupId) async {
    try {
      await datasource.deleteGroup(userId, groupId);
      return Result.success(null); // Void success
    } catch (e) {
      return Result.error(ServerFailure("Error al eliminar grupo: $e"));
    }
  }

  @override
  Future<Result<List<GroupMember>>> getGroupMembers(
    String userId,
    String groupId,
  ) async {
    try {
      final result = await datasource.getGroupMembers(userId, groupId);
      return Result.success(result);
    } catch (e) {
      return Result.error(ServerFailure("Error al obtener miembros: $e"));
    }
  }

  @override
  Future<Result<void>> removeMember(String groupId, String memberId) async {
    try {
      await datasource.removeMember(groupId, memberId);
      return Result.success(null);
    } catch (e) {
      return Result.error(ServerFailure("Error al eliminar miembro: $e"));
    }
  }

  @override
  Future<Result<void>> transferAdmin(
    String userId,
    String groupId,
    String newAdminId,
  ) async {
    try {
      await datasource.transferAdmin(userId, groupId, newAdminId);
      return Result.success(null);
    } catch (e) {
      return Result.error(
        ServerFailure("Error al transferir administrador: $e"),
      );
    }
  }

  @override
  Future<Result<GroupInvitation>> generateInvitation(
    String userId,
    String groupId,
  ) async {
    try {
      final result = await datasource.generateInvitation(userId, groupId);
      return Result.success(result);
    } catch (e) {
      return Result.error(ServerFailure("Error al generar invitación: $e"));
    }
  }

  @override
  Future<Result<Group>> joinGroup(String userId, String token) async {
    try {
      final result = await datasource.joinGroup(userId, token);
      return Result.success(result);
    } catch (e) {
      return Result.error(ServerFailure("Error al unirse al grupo: $e"));
    }
  }

  @override
  Future<Result<void>> assignQuiz(
    String userId,
    String groupId,
    String quizId,
    DateTime from,
    DateTime until,
  ) async {
    try {
      await datasource.assignQuiz(userId, groupId, quizId, from, until);
      return Result.success(null);
    } catch (e) {
      return Result.error(ServerFailure("Error al asignar quiz: $e"));
    }
  }

  @override
  Future<Result<List<AssignedQuiz>>> getGroupQuizzes(
    String userId,
    String groupId,
  ) async {
    try {
      final result = await datasource.getGroupQuizzes(userId, groupId);
      return Result.success(result);
    } catch (e) {
      return Result.error(ServerFailure("Error al obtener quizzes: $e"));
    }
  }

  @override
  Future<Result<List<LeaderboardEntry>>> getGroupLeaderboard(
    String userId,
    String groupId,
  ) async {
    try {
      final result = await datasource.getGroupLeaderboard(userId, groupId);
      return Result.success(result);
    } catch (e) {
      return Result.error(ServerFailure("Error al obtener ranking: $e"));
    }
  }

  @override
  Future<Result<List<LeaderboardEntry>>> getQuizLeaderboard(
    String userId,
    String groupId,
    String quizId,
  ) async {
    try {
      final result = await datasource.getQuizLeaderboard(
        userId,
        groupId,
        quizId,
      );
      return Result.success(result);
    } catch (e) {
      return Result.error(
        ServerFailure("Error al obtener ranking del quiz: $e"),
      );
    }
  }
}
