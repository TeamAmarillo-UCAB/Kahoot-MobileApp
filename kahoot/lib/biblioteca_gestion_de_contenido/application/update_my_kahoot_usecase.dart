import '../infrastructure/repository/library_kahoot_repository_impl.dart';
import '../../../core/result.dart';
import '../../../Creacion_edicion_quices/domain/entities/question.dart';
import '../../../Creacion_edicion_quices/domain/entities/answer.dart';

class UpdateMyKahootUseCase {
  final LibraryKahootRepositoryImpl repository;

  UpdateMyKahootUseCase({required this.repository});

  Future<Result<void>> call(String kahootId, String title, String description, String image, String visibility, String status, String theme, List<Question> question, List<Answer> answer) {
    return repository.updateMyKahoot(kahootId, title, description, image, visibility, status, theme, question, answer);
  }
}