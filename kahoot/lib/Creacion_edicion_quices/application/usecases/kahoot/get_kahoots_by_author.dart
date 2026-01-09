import '../../../core/result.dart';
import '../../../domain/entities/kahoot.dart';
import '../../../domain/repositories/kahoot_repository.dart';

class GetKahootsByAuthor {
  final KahootRepository repository;
  GetKahootsByAuthor(this.repository);

  Future<Result<List<Kahoot>>> call(String authorId) async {
    return await repository.getKahootsByAuthor(authorId);
  }
}
