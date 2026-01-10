import '../domain/repositories/library_repository.dart';
import '../../../core/result.dart';

class RemoveKahootFromFavoriteUseCase {
  final KahootRepository repository;

  RemoveKahootFromFavoriteUseCase({required this.repository});

  Future<Result<void>> call(String kahootId) {
    return repository.removeKahootFromFavorites(kahootId);
  }
}