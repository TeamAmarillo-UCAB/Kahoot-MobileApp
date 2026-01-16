import '../domain/repositories/library_repository.dart';
import '../../Creacion_edicion_quices/domain/entities/category.dart';
import '../../../core/result.dart';

class GetCategoryUseCase {
  final KahootRepository repository;

  GetCategoryUseCase({required this.repository});

  Future<Result<List<Category>>> call() {
    return repository.getCategory();
  }
}
