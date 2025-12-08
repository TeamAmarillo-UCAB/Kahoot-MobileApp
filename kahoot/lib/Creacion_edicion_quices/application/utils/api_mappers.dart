import '../../domain/entities/question.dart';
import '../../domain/entities/kahoot.dart';

/// Mapea enums/dominio a valores esperados por la API
class ApiMappers {
  static String mapVisibility(KahootVisibility v) {
    switch (v) {
      case KahootVisibility.public:
        return 'public';
      case KahootVisibility.private:
        return 'private';
    }
  }

  static String mapQuestionType(QuestionType t) {
    switch (t) {
      case QuestionType.true_false:
        return 'true_false';
      case QuestionType.quiz_single:
      case QuestionType.quiz_multiple:
        return 'quiz';
      default:
        return 'quiz';
    }
  }
}
