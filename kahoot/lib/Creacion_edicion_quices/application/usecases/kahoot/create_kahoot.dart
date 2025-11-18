import '../../../domain/repositories/kahoot_repository.dart';
import '../../../domain/entities/quiz.dart';

class CreateKahoot {
  final KahootRepository repository;

  CreateKahoot(this.repository);

  Future<void> call(int id, String title, String description, String image, String theme, DateTime creationDate, String status, String visibility, List<Quiz> quiz) async {
    return await repository.createKahoot(id, title, description, image, theme, creationDate, status, visibility, quiz);
  }
}