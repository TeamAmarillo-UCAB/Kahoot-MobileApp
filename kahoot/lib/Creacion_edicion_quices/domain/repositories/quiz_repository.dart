import '../entities/quiz.dart';

abstract class QuizRepository{
  Future<void> createQuiz(int id, String question, List<String> options, String correctAnswer);
  Future<void> updateQuiz(Quiz quiz);
  Future<void> deleteQuiz(String id);
  Future<Quiz> getQuiz();
}