import '../../domain/entities/answer.dart';

class AnswerModel extends Answer{

  AnswerModel({
    required super.answerId,
    required super.image,
    required super.isCorrect,
    required super.text,
    required super.questionId
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json, String questionId) {
    final aId = json['answerId']?.toString() ?? (json['id']?.toString() ?? '');
    final aText = json['answerText'] ?? json['text'] ?? '';
    final aImage = json['mediaId'] ?? json['image'] ?? '';
    final aIsCorrect = json['isCorrect'] is bool ? json['isCorrect'] as bool : (json['isCorrect']?.toString().toLowerCase() == 'true');

    return AnswerModel(
      answerId: aId,
      image: aImage ?? '',
      isCorrect: aIsCorrect,
      text: aText,
      questionId: questionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answerText': text,
      'mediaId': image.isEmpty ? null : image,
      'isCorrect': isCorrect,
    };
  }
}