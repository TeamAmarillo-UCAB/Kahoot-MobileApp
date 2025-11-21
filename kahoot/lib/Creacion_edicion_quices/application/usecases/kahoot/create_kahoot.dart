import '../../../domain/repositories/kahoot_repository.dart';
import '../../../domain/entities/question.dart';
import '../../../domain/entities/answer.dart';

class CreateKahoot {
  final KahootRepository repository;

  CreateKahoot(this.repository);

  Future<void> call(String kahootId, String authorId, String title, String description, String image, String theme, String visibility, List<Question> question, List<Answer> answer) async {
    return await repository.createKahoot(kahootId, authorId, title, description, image, visibility, theme, question, answer);
  }
}