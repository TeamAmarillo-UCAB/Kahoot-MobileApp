import '../../domain/entities/kahoot.dart';
import 'question_model.dart';
import 'answer_model.dart';

class KahootModel extends Kahoot{
  KahootModel({
    required super.kahootId, 
    required super.title, 
    required super.description, 
    required super.image, 
    required super.theme, 
    required super.creationDate, 
    required super.status, 
    required super.visibility, 
    required super.quiz, 
    required super.answers
  });

  factory KahootModel.fromJson(Map<String, dynamic> json) {
    final kahootId = json['id']?.toString() ?? json['kahootId']?.toString() ?? '';
    final title = json['title'] ?? '';
    final description = json['description'] ?? '';
    final image = json['coverImageId'] ?? json['image'] ?? '';
    final theme = json['themeId'] ?? json['theme'] ?? '';

    DateTime creationDate;
    if (json['createdAt'] != null) {
      try {
        creationDate = DateTime.parse(json['createdAt'].toString());
      } catch (_) {
        creationDate = DateTime.now();
      }
    } else if (json['creationDate'] != null) {
      try {
        creationDate = DateTime.parse(json['creationDate'].toString());
      } catch (_) {
        creationDate = DateTime.now();
      }
    } else {
      creationDate = DateTime.now();
    }

    final status = KahootStatusX.fromString(json['status']?.toString() ?? 'draft');
    final visibility = KahootVisibilityX.fromString(json['visibility']?.toString() ?? 'private');

    final questionsJson = json['questions'] as List<dynamic>? ?? [];
    final questions = questionsJson.map((q) => QuestionModel.fromJson(q as Map<String, dynamic>)).toList();

    final List<AnswerModel> allAnswers = [];
    for (final q in questions) {
      allAnswers.addAll(q.answer.map((a) => a as AnswerModel));
    }

    return KahootModel(
      kahootId: kahootId,
      title: title,
      description: description,
      image: image ?? '',
      theme: theme ?? '',
      creationDate: creationDate,
      status: status,
      visibility: visibility,
      quiz: questions,
      answers: allAnswers,
    );
  }

  Map<String, dynamic> toJson({required String authorId}) {
    return {
      'authorId': authorId,
      'title': title,
      'description': description,
      'coverImageId': image.isEmpty ? null : image,
      'visibility': visibility.toShortString(),
      'themeId': theme.isEmpty ? null : theme,
      'status': status.toShortString(),
      'questions': quiz.map((q) => (q as QuestionModel).toJson()).toList(),
    };
  }
}