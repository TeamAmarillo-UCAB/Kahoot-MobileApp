import '../../../core/result.dart';
import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import '../../domain/entities/category.dart';

abstract class ExploreRepository {
  Future<Result<List<Category>>> getCategories();
  Future<Result<List<Kahoot>>> getKahootsByCategory(String category);
}