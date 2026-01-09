import '../../../core/result.dart';
import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';

abstract class KahootRepository {
  Future<Result<List<Kahoot>>> getMyKahoots();
}