import '../../domain/entities/question_slide.dart';

class QuestionMapper {
  static QuestionSlide fromWs(Map<String, dynamic> json) {
    return QuestionSlide.fromJson(json);
  }
}
