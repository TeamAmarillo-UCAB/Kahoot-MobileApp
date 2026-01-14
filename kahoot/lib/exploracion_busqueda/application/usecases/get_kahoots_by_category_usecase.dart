import '../../domain/repositories/explore_repository.dart';
import '../../../core/result.dart';
import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';

class GetKahootsByCategoryUseCase {
  final ExploreRepository repository;

  GetKahootsByCategoryUseCase({required this.repository});

  Future<Result<List<Kahoot>>> call(String category) {
    return repository.getKahootsByCategory(category);
  }
}