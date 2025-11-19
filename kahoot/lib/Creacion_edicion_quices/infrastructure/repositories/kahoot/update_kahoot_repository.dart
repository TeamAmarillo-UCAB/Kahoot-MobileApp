import '../local/kahoot_model.dart';

abstract class UpdateKahootRepository {
  /// Persists an updated Kahoot model (local DB, cache, or preparing payload).
  Future<void> updateKahoot(KahootModel kahoot);
}
