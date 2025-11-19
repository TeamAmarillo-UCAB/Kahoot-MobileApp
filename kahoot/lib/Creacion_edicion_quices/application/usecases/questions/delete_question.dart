import '../../../domain/repositories/question_repository.dart';

class DeleteQuestions{
  final QuestionRepository repository;

  DeleteQuestions(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteQuestion(id);
  }
}