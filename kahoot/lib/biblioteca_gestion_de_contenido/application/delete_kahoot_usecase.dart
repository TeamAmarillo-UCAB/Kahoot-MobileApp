import '../domain/repositories/library_repository.dart';
import '../../../core/result.dart';

class DeleteKahootUseCase {
  final KahootRepository repository;

  DeleteKahootUseCase({required this.repository});

  Future<Result<void>> call(String kahootId) {
    return repository.deleteKahoot(kahootId);
  }
}