import '../entities/answer.dart';
import '../entities/question.dart';

abstract class AnswerRepository{
  Future<void> createAnswer(int answerId, String image, bool isCorrect, String text, Question questionId);
  Future<void> updateAnswer(Answer answer);
  Future<void> deleteAnswer(int answerId);
  Future<List<dynamic>> getAnswers();
}