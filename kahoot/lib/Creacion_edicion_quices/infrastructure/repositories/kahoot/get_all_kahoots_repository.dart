import '../local/kahoot_model.dart';

abstract class GetAllKahootsRepository {
  /// Returns all stored Kahoot models (local DB, cache) or maps remote response to models.
  Future<List<KahootModel>> getAllKahoots();
}
