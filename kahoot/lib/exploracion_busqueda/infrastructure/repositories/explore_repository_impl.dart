import '../../domain/datasource/explore_datasource.dart';
import '../../domain/repositories/explore_repository.dart';
import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import '../../../core/result.dart';
import '../../domain/entities/category.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreDatasource datasource;

  ExploreRepositoryImpl({required this.datasource});

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final categories = await datasource.getCategories();
      return Result.success(categories);
    } catch (e, stackTrace) {
      print("Error fetching categories: $e");
      print("Stacktrace: $stackTrace");
      return Result.makeError(Exception(e));
    }
  }

  @override
  Future<Result<List<Kahoot>>> getKahootsByCategory(String category) async {
    try {
      final kahoots = await datasource.getKahootsByCategory(category);
      return Result.success(kahoots);
    } catch (e, stackTrace) {
      print("Error fetching kahoots by category: $e");
      print("Stacktrace: $stackTrace");
      return Result.makeError(Exception(e));
    }
  }
}