import '../domain/repositories/library_repository.dart';
import '../../../core/result.dart';

class AddKahootToFavoriteUseCase {
  final KahootRepository repository;

  AddKahootToFavoriteUseCase({required this.repository});

  Future<Result<void>> call(String kahootId) {
    return repository.addKahootToFavorites(kahootId);
  }
}