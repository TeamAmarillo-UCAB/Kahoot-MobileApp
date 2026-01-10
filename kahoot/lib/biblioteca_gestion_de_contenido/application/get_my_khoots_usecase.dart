import '../domain/repositories/library_repository.dart';
import '../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import '../../../core/result.dart';

class GetMyKhootsUseCase {
  final KahootRepository repository;

  GetMyKhootsUseCase({required this.repository});

  Future<Result<List<Kahoot>>> call() {
    return repository.getMyKahoots();
  }
}