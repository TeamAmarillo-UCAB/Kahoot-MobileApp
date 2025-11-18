enum AnswerType { quizSingle, quizMultiple, trueFalse, shortAnswer, poll, slide }

extension AnswerTypeX on AnswerType {
  String toShortString() => toString().split('.').last;
  static AnswerType fromString(String value) {
    final normalized = value.replaceAll(' ', '_').toLowerCase();
    return AnswerType.values.firstWhere(
      (e) => e.toShortString().toLowerCase() == normalized,
      orElse: () => AnswerType.quizSingle,
    );
  }
}

class Slide{
  final String id;
  final String content;
  final int points;
  final int timeLimit;
  final String answer;
  final bool isCorrect;
  final String urlImage;
  final AnswerType type;


  Slide({
    required this.id,
    required this.content,
    required this.points,
    required this.timeLimit,
    required this.answer,
    required this.isCorrect,
    this.urlImage = '',
    required this.type,
  });
}