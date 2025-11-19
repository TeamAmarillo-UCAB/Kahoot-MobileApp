import '../../../domain/repositories/question_repository.dart';
import '../../../domain/entities/question.dart';
class UpdateQuestion {
  final QuestionRepository repository;

  UpdateQuestion(this.repository);

  Future<void> call(Question question) async {
    return await repository.updateQuestion(question);
  }
}