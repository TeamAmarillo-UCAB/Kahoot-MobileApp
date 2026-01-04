import 'package:dio/dio.dart';
import '../../domain/datasources/group_datasource.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_detail.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/group_invitation.dart';
import '../../domain/entities/assigned_quiz.dart';
import '../../domain/entities/leaderboard_entry.dart';

class GroupDatasourceImpl implements GroupDatasource {
  final Dio dio;

  GroupDatasourceImpl({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://quizzy-backend-0wh2.onrender.com/api',
              headers: {'Content-Type': 'application/json'},
            ),
          );

  // Helper para inyectar el userId en los headers
  Options _getOptions(String userId) => Options(headers: {'userId': userId});

  @override
  Future<List<Group>> getMyGroups(String userId) async {
    final response = await dio.get('/groups', options: _getOptions(userId));
    return (response.data as List).map((e) => Group.fromJson(e)).toList();
  }

  @override
  Future<GroupDetail> createGroup(
    String userId,
    String name,
    String description,
  ) async {
    final response = await dio.post(
      '/groups',
      data: {'name': name, 'description': description},
      options: _getOptions(userId),
    );
    return GroupDetail.fromJson(response.data);
  }

  @override
  Future<GroupDetail> editGroup(
    String userId,
    String groupId,
    String name,
    String description,
  ) async {
    // Nota: Usamos la ruta REST estándar para editar recurso.
    // Si la API requiere estrictamente la ruta rara del prompt, cambiar a: '/groups/$groupId/members/algo'
    final response = await dio.patch(
      '/groups/$groupId',
      data: {'name': name, 'description': description},
      options: _getOptions(userId),
    );
    return GroupDetail.fromJson(response.data);
  }

  @override
  Future<void> deleteGroup(String userId, String groupId) async {
    await dio.delete('/groups/$groupId', options: _getOptions(userId));
  }

  @override
  Future<List<GroupMember>> getGroupMembers(
    String userId,
    String groupId,
  ) async {
    final response = await dio.get(
      '/groups/$groupId/members',
      options: _getOptions(userId),
    );
    return (response.data as List).map((e) => GroupMember.fromJson(e)).toList();
  }

  @override
  Future<void> removeMember(
    String userId,
    String groupId,
    String memberId,
  ) async {
    await dio.delete(
      '/groups/$groupId/members/$memberId',
      options: _getOptions(userId),
    );
  }

  @override
  Future<Map<String, dynamic>> transferAdmin(
    String userId,
    String groupId,
    String newAdminId,
  ) async {
    final response = await dio.patch(
      '/groups/$groupId/transfer-admin',
      data: {'newAdminId': newAdminId},
      options: _getOptions(userId),
    );
    return response.data;
  }

  @override
  Future<GroupInvitation> generateInvitation(
    String userId,
    String groupId,
  ) async {
    final response = await dio.post(
      '/groups/$groupId/invitations',
      options: _getOptions(userId),
    );
    return GroupInvitation.fromJson(response.data);
  }

  @override
  Future<Group> joinGroup(String userId, String token) async {
    final response = await dio.post(
      '/groups/join',
      data: {'invitationToken': token},
      options: _getOptions(userId),
    );

    // Mapeo manual porque la respuesta de este endpoint (Endpoint 8) es ligeramente
    // diferente a la entidad Group estándar (no trae memberCount, por ejemplo).
    final data = response.data;
    return Group(
      id: data['groupId'],
      name: data['groupName'],
      role: data['role'],
      memberCount: 1, // Valor placeholder ya que la API no lo devuelve aquí
      createdAt: DateTime.tryParse(data['joinedAt'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  Future<void> assignQuiz(
    String userId,
    String groupId,
    String quizId,
    DateTime from,
    DateTime until,
  ) async {
    await dio.post(
      '/groups/$groupId/quizzes',
      data: {
        'quizId': quizId,
        'availableFrom': from.toIso8601String(),
        'availableUntil': until.toIso8601String(),
      },
      options: _getOptions(userId),
    );
  }

  @override
  Future<List<AssignedQuiz>> getGroupQuizzes(
    String userId,
    String groupId,
  ) async {
    final response = await dio.get(
      '/groups/$groupId/quizzes',
      options: _getOptions(userId),
    );
    // Importante: La API devuelve { "data": [...] } según el Endpoint 10
    final dataList = response.data['data'] as List;
    return dataList.map((e) => AssignedQuiz.fromJson(e)).toList();
  }

  @override
  Future<List<LeaderboardEntry>> getGroupLeaderboard(
    String userId,
    String groupId,
  ) async {
    final response = await dio.get(
      '/groups/$groupId/leaderboard',
      options: _getOptions(userId),
    );
    return (response.data as List)
        .map((e) => LeaderboardEntry.fromJson(e))
        .toList();
  }

  @override
  Future<List<LeaderboardEntry>> getQuizLeaderboard(
    String userId,
    String groupId,
    String quizId,
  ) async {
    final response = await dio.get(
      '/groups/$groupId/quizzes/$quizId/leaderboard',
      options: _getOptions(userId),
    );
    // Endpoint 12 devuelve { "topPlayers": [...] }
    final players = response.data['topPlayers'] as List;
    return players.map((e) => LeaderboardEntry.fromJson(e)).toList();
  }
}
