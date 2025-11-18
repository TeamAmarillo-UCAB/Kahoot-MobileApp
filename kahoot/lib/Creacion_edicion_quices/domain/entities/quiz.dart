import 'answer.dart';
import 'question.dart';

class Quiz{
  final int quizId;
  final String description;
  final String title;
  final String image;
  final List<Question> questions;
  final List<Answer> answers;

  Quiz({
    required this.quizId,
    required this.description,
    required this.title,
    required this.image,
    required this.questions,
    required this.answers,
  });
}