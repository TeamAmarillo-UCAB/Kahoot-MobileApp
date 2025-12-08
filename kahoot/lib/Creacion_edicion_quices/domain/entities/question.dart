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

class Question {
  final String text;
  final String title;
  final String mediaId;
  final QuestionType type;
  final int points;
  final int timeLimitSeconds; // seconds
  final List<Answer> answer;

  Question({
    required this.text,
    required this.title,
    required this.mediaId,
    required this.type,
    required this.points,
    required this.timeLimitSeconds,
    required this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['text'] as String? ?? '',
      title: json['title'] as String? ?? '',
      mediaId: json['mediaId'] as String? ?? '',
      type: QuestionTypeX.fromString(json['type'] as String? ?? 'quiz_single'),
      points: json['points'] as int? ?? 0,
      timeLimitSeconds: json['timeLimitSeconds'] as int? ?? 0,
      answer: Answer.fromJsonList(json['answers'] as List<dynamic>),
    );
  }

  static List<Question> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Question.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}