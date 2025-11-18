import 'question.dart';

class Answer{
  final int answerId;
  final String image;
  final bool isCorrect;
  final String text;
  final Question questionId;

  Answer({
    required this.answerId,
    required this.image,
    required this.isCorrect,
    required this.text,
    required this.questionId,
  });

}