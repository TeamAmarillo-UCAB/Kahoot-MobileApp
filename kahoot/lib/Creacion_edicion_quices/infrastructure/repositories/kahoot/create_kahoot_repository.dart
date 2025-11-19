
import '../../local/question_model.dart';
import '../../local/answer_model.dart';

abstract class CreateKahootRepository {
  Future<void> createKahoot(int id, String title, String description, String image, String theme, DateTime creationDate, String status, String visibility, List<QuestionModel> quiz, List<AnswerModel> answers);

}