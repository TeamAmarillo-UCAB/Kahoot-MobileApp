import '../entities/answer.dart';

abstract class AnswerRepository{
  Future<void> createAnswer(int answerId, String image, bool isCorrect, String text, String questionId);
  Future<void> updateAnswer(Answer answer);
  Future<void> deleteAnswer(int answerId);
  Future<List<Answer>> getAnswers();
}