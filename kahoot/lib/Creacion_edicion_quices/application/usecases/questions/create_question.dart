import '../../../domain/repositories/question_repository.dart';

class CreateQuestion{
  final QuestionRepository repository;

  CreateQuestion(this.repository);

  Future<void> call(int id, String title, String type, int points, DateTime timeLimitSeconds, List<dynamic> answers) async {
    return await repository.createQuestion(id, title, type, points, timeLimitSeconds, answers);
  }
}