import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import '../../domain/entities/category.dart';

abstract class ExploreDatasource {
  Future<List<Category>> getCategories();
  Future<List<Kahoot>> getKahootsByCategory(String category);
}


