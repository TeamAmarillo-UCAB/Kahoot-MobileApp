import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';

abstract class LibraryDatasource {
  Future<List<Kahoot>> getMyKahoots();
}