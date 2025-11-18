import'../../../domain/repositories/kahoot_repository.dart';
import '../../../domain/entities/kahoot.dart';

class GetAllKahoots{
  final KahootRepository repository;

  GetAllKahoots(this.repository);
  Future<List<Kahoot>> call() async {
    return await repository.getAllKahoots();
  }
}