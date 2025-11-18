import '../entities/kahoot.dart';
import '../entities/quiz.dart';
abstract class KahootRepository {
  Future<void> createKahoot(int id, String title, String description, String image, String theme, DateTime creationDate, String status, String visibility, List<Quiz> quiz);
  Future<void> updateKahoot(Kahoot kahoot);
  Future <void> deleteKahoot(String id);
  Future<List<Kahoot>> getAllKahoots();
}