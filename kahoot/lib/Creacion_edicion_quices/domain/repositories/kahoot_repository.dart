import '../entities/question.dart';
import '../entities/answer.dart';
import '../entities/kahoot.dart';
abstract class KahootRepository {
  Future<void> createKahoot(int id, String title, String description, String image, String theme, DateTime creationDate, String status, String visibility, List<Question> quiz, List<Answer> answers);
  Future<void> updateKahoot(Kahoot kahoot);
  Future <void> deleteKahoot(String id);
  Future<List<Kahoot>> getAllKahoots();
}