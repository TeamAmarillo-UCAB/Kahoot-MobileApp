import '../../../domain/repositories/kahoot_repository.dart';

class DeleteKahoot {
  final KahootRepository repository;

  DeleteKahoot(this.repository);

  Future<void> call(String id) async {
    await repository.deleteKahoot(id);
  }
}