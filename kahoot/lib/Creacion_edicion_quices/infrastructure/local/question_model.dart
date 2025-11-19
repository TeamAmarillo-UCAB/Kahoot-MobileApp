
import 'package:kahoot/Creacion_edicion_quices/domain/entities/question.dart';
import 'answer_model.dart';

class QuestionModel extends Question{

  QuestionModel({
    required super.questionId, 
    required super.title, 
    required super.type, 
    required super.points, 
    required super.timeLimitSeconds, 
    required super.answer
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final qId = json['questionId']?.toString() ?? (json['id']?.toString() ?? '');
    final qTitle = json['questionText'] ?? json['title'] ?? '';
    final qType = QuestionTypeX.fromString(json['questionType']?.toString() ?? 'quiz_single');
    final qPoints = json['points'] is int ? json['points'] as int : (int.tryParse(json['points']?.toString() ?? '') ?? 0);
    final qTime = json['timeLimit'] is int ? json['timeLimit'] as int : (int.tryParse(json['timeLimit']?.toString() ?? '') ?? 0);

    final answersJson = json['answers'] as List<dynamic>? ?? [];
    final answers = answersJson.map((a) => AnswerModel.fromJson(a as Map<String, dynamic>, qId)).toList();

    return QuestionModel(
      questionId: qId,
      title: qTitle,
      type: qType,
      points: qPoints,
      timeLimitSeconds: qTime,
      answer: answers,
    );
  }

  Map<String, dynamic> toJson() {
    String questionTypeApi;
    switch (type) {
      case QuestionType.quiz_single:
      case QuestionType.quiz_multiple:
        questionTypeApi = 'quiz';
        break;
      case QuestionType.true_false:
        questionTypeApi = 'true_false';
        break;
      case QuestionType.short_answer:
        questionTypeApi = 'short_answer';
        break;
      case QuestionType.poll:
        questionTypeApi = 'poll';
        break;
      case QuestionType.slide:
        questionTypeApi = 'slide';
        break;
    }

    return {
      'questionId': questionId,
      'questionText': title,
      'mediaId': null,
      'questionType': questionTypeApi,
      'timeLimit': timeLimitSeconds,
      'points': points,
      'answers': answer.map((a) => (a as AnswerModel).toJson()).toList(),
    };
  }
}