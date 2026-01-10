import '../../common/core/result.dart';
import '../../domain/repositories/group_repository.dart';

class AssignQuiz {
  final GroupRepository repository;

  AssignQuiz(this.repository);

  Future<Result<void>> call(
    String userId,
    String groupId,
    String quizId,
    DateTime availableFrom,
    DateTime availableUntil,
  ) {
    return repository.assignQuiz(
      userId,
      groupId,
      quizId,
      availableFrom,
      availableUntil,
    );
  }
}
