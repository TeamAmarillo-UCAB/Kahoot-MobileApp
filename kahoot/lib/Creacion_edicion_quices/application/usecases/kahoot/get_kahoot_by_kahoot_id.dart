import '../../../core/result.dart';
import '../../../domain/entities/kahoot.dart';
import '../../../domain/repositories/kahoot_repository.dart';

class GetKahootByKahootId {
  final KahootRepository repository;
  GetKahootByKahootId(this.repository);

  Future<Result<Kahoot?>> call(String kahootId) async {
    return await repository.getKahootByKahootId(kahootId);
  }
}
