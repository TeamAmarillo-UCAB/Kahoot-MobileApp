import 'answer_option.dart';

class Question {
  final int questionIndex;
  final String questionText;
  final String? mediaUrl;
  final int timeLimitSeconds;
  final List<AnswerOption> options;

  Question({
    required this.questionIndex,
    required this.questionText,
    this.mediaUrl,
    required this.timeLimitSeconds,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    questionIndex: json['questionIndex'] as int,
    questionText: json['currentSlideData']['questionText'] as String,
    mediaUrl: json['currentSlideData']['mediaUrl'] as String?,
    timeLimitSeconds: json['timeLimitSeconds'] as int,
    options: (json['currentSlideData']['options'] as List)
        .map((o) => AnswerOption.fromJson(o as Map<String, dynamic>))
        .toList(),
  );
}
