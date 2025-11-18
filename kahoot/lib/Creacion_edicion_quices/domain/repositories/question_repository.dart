import '../entities/question.dart';

abstract class QuestionRepository{
  Future<void> createQuestion(int id, String title, String type, int points, DateTime timeLimitSeconds, List<dynamic> answers);
  Future<void> updateQuestion(Question question);
  Future<void> deleteQuestion(String id);
  Future<Question> getQuestion();
}