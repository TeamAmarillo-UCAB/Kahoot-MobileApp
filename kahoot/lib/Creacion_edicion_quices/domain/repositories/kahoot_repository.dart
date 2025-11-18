import '../entities/kahoot.dart';
import '../entities/slide.dart';
abstract class KahootRepository {
  Future<void> createKahoot(int id, String title, String description, String image, String theme, DateTime creationDate, String status, String visibility, List<Slide> questions);
  Future<void> updateKahoot(Kahoot kahoot);
  Future <void> deleteKahoot(String id);
  Future<List<Kahoot>> getAllKahoots();
}