import '../../common/core/result.dart'; // O la ruta donde tengas tu Result
import '../../domain/entities/group_member.dart';
import '../../domain/entities/assigned_quiz.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/group_repository.dart';

/// Clase auxiliar para agrupar la respuesta
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
    // 1. Ejecución en paralelo
    final results = await Future.wait([
      repository.getGroupMembers(userId, groupId),
      repository.getGroupQuizzes(userId, groupId),
      repository.getGroupLeaderboard(userId, groupId),
    ]);

    // 2. Casteo de resultados
    final membersResult = results[0] as Result<List<GroupMember>>;
    final quizzesResult = results[1] as Result<List<AssignedQuiz>>;
    final leaderboardResult = results[2] as Result<List<LeaderboardEntry>>;

    // 3. Verificación de éxito (Miembros y Quizzes son obligatorios)
    if (membersResult.isSuccessful() && quizzesResult.isSuccessful()) {
      return Result.success(
        GroupFullData(
          members: membersResult.getValue(),
          quizzes: quizzesResult.getValue(),
          // Leaderboard es opcional/secundario
          leaderboard: leaderboardResult.isSuccessful()
              ? leaderboardResult.getValue()
              : [],
        ),
      );
    } else {
      // 4. Manejo de errores ROBUSTO
      String errorMsg;

      // Verificamos cuál falló realmente para no causar un crash
      if (!membersResult.isSuccessful()) {
        errorMsg = membersResult.getError().toString();
      } else {
        // Si members está bien, entonces quizzes falló
        errorMsg = quizzesResult.getError().toString();
      }

      return Result.error(Exception(errorMsg));
    }
  }
}
