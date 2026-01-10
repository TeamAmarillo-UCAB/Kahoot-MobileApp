import '../../../core/result.dart';
import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';

abstract class KahootRepository {
  Future<Result<List<Kahoot>>> getMyKahoots();
  Future<Result<void>> addKahootToFavorites(String kahootId);
  Future<Result<void>> removeKahootFromFavorites(String kahootId);
}