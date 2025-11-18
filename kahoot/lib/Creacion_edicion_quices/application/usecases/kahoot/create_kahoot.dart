import '../../../domain/repositories/kahoot_repository.dart';
import '../../../domain/entities/slide.dart';

class CreateKahoot {
  final KahootRepository repository;

  CreateKahoot(this.repository);

  Future<void> call(int id, String title, String description, String image, String theme, DateTime creationDate, String status, String visibility, List<Slide> questions) async {
    return await repository.createKahoot(id, title, description, image, theme, creationDate, status, visibility, questions);
  }
}