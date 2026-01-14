import '../../domain/repositories/explore_repository.dart';
import '../../../core/result.dart';
import '../../domain/entities/category.dart';

class GetCategoriesUseCase {
  final ExploreRepository repository;

  GetCategoriesUseCase({required this.repository});

  Future<Result<List<Category>>> call() {
    return repository.getCategories();
  }
}