import '../../../domain/entities/question.dart';
import '../../../domain/repositories/question_repository.dart';

class GetQuestion{
  final QuestionRepository repository;

  GetQuestion(this.repository);
  Future<Question> call() async {
    return await repository.getQuestion();
  }
}