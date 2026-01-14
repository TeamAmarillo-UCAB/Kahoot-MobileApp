import '../../common/core/result.dart';
import '../../domain/entities/assigned_quiz.dart';
import '../../domain/repositories/group_repository.dart';

class GetGroupQuizzes {
  final GroupRepository repository;

  GetGroupQuizzes(this.repository);

  Future<Result<List<AssignedQuiz>>> call(String userId, String groupId) {
    return repository.getGroupQuizzes(userId, groupId);
  }
}
