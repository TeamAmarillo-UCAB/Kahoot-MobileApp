import '../../../domain/entities/question.dart';
import '../../../domain/repositories/answer_repository.dart';

class CreateAnswer{
  final AnswerRepository repository;

  CreateAnswer(this.repository);
  Future<void> call(int answerId, String image, bool isCorrect, String text, Question questionId) async {
    return await repository.createAnswer(answerId, image, isCorrect, text, questionId);
  }
}