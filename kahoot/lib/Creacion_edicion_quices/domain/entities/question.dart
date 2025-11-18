import 'answer.dart';

enum QuestionType { quiz_single, quiz_multiple, true_false, short_answer, poll, slide }

extension QuestionTypeX on QuestionType {
  String toShortString() => toString().split('.').last;
  static QuestionType fromString(String value) {
    final normalized = value.replaceAll(' ', '_').toLowerCase();
    // accept common typo 'pool' as 'poll'
    final normalizedFixed = normalized == 'pool' ? 'poll' : normalized;
    return QuestionType.values.firstWhere(
      (e) => e.toShortString().toLowerCase() == normalizedFixed,
      orElse: () => QuestionType.quiz_single,
    );
  }
}

class Question{
  final int questionId;
  final String title;
  final QuestionType type;
  final int points;
  final DateTime timeLimitSeconds;
  final List<Answer> answer;

  Question({
    required this.questionId,
    required this.title,
    required this.type,
    required this.points,
    required this.timeLimitSeconds,
    required this.answer,
  });
}