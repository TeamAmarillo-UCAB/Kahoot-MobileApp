import '../../../core/result.dart';
import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';

class SearchKahootsByTitleUseCase {
  const SearchKahootsByTitleUseCase();

  Future<Result<List<Kahoot>>> call(String title) async {
    return Result.makeError(
      Exception('Title search has been disabled. Use category search.'),
    );
  }
}
