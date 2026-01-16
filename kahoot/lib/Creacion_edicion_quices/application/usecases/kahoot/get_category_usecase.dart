import '../../../../core/result.dart';
import '../../../domain/repositories/kahoot_repository.dart';
import '../../../domain/entities/category.dart';

class GetCategory {
  final KahootRepository repository;

  GetCategory(this.repository);

  Future<Result<List<Category>>> call() async {
    return await repository.getCategory();
  }
}
