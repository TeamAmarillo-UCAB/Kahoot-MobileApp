import 'package:dio/dio.dart';
import '../../domain/datasources/group_datasource.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_detail.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/group_invitation.dart';
import '../../domain/entities/assigned_quiz.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../../core/auth_state.dart';

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
          ) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthState.token.value;
          //const String jwtToken = //HARDCODEADOOOOOOOO
          //"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjdhYmM2ZmVkLTY2NWUtNDYzZC1iNTRkLThkNzhjMTM5N2U2ZiIsImVtYWlsIjoibmNhcmxvc0BleGFtcGxlLmNvbSIsInJvbGVzIjpbInVzZXIiXSwiaWF0IjoxNzY4MDI0MDM5LCJleHAiOjE3NjgwMzEyMzl9._3Ks0CS4afQo0pJ1wHTjNLfk1m-A_rjH_OIXLxYG-u8";

          // Inyección del Token Bearer
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Manejo de errores global
          return handler.next(e);
        },
      ),
    );
  }

  @override
  Future<List<Group>> getMyGroups(String userId) async {
    final response = await dio.get('/groups');
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
    final response = await dio.patch(
      '/groups/$groupId',
      data: {'name': name, 'description': description},
    );
    return GroupDetail.fromJson(response.data);
  }

  @override
  Future<void> deleteGroup(String userId, String groupId) async {
    await dio.delete('/groups/$groupId');
  }

  @override
  Future<List<GroupMember>> getGroupMembers(
    String userId,
    String groupId,
  ) async {
    final response = await dio.get('/groups/$groupId/members');
    return (response.data as List).map((e) => GroupMember.fromJson(e)).toList();
  }

  @override
  Future<void> removeMember(String groupId, String memberId) async {
    await dio.delete('/groups/$groupId/members/$memberId');
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
    );
    return response.data;
  }

  @override
  Future<GroupInvitation> generateInvitation(
    String userId,
    String groupId,
  ) async {
    final response = await dio.post('/groups/$groupId/invitations');
    return GroupInvitation.fromJson(response.data);
  }

  @override
  Future<Group> joinGroup(String userId, String token) async {
    final response = await dio.post(
      '/groups/join',
      data: {'invitationToken': token},
    );

    final data = response.data;
    return Group(
      id: data['groupId'],
      name: data['groupName'],
      description: data['groupName'],
      role: data['role'],
      memberCount: 1, // Placeholder
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
    );
  }

  @override
  Future<List<AssignedQuiz>> getGroupQuizzes(
    String userId,
    String groupId,
  ) async {
    final response = await dio.get('/groups/$groupId/quizzes');
    final dataList = response.data['data'] as List;
    return dataList.map((e) => AssignedQuiz.fromJson(e)).toList();
  }

  @override
  Future<List<LeaderboardEntry>> getGroupLeaderboard(
    String userId,
    String groupId,
  ) async {
    final response = await dio.get('/groups/$groupId/leaderboard');
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
    );
    // Endpoint 12 devuelve { "topPlayers": [...] }
    final players = response.data['topPlayers'] as List;
    return players.map((e) => LeaderboardEntry.fromJson(e)).toList();
  }
}
