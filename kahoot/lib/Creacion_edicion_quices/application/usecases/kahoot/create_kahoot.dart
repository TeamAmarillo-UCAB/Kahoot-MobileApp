import '../../../domain/repositories/kahoot_repository.dart';
import '../../../domain/entities/question.dart';
import '../../../domain/entities/answer.dart';
import '../../../../core/result.dart';

class CreateKahoot {
  final KahootRepository repository;

  CreateKahoot(this.repository);

  // Order fixed: visibility first, then theme to align with repository/datasource
  Future<Result<void>> call(String kahootId, String authorId, String title, String description, String image, String visibility, String status, String theme, List<Question> question, List<Answer> answer) async {
    return await repository.createKahoot(kahootId, authorId, title, description, image, visibility, status, theme, question, answer);
  }
}