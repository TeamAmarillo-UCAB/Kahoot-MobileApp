import '../../../domain/repositories/kahoot_repository.dart';
import '../../../domain/entities/kahoot.dart';
class UpdateKahoot {
  final KahootRepository repository;

  UpdateKahoot(this.repository);

  Future<void> call(Kahoot kahoot) async {
    return await repository.updateKahoot(kahoot);
  }
}