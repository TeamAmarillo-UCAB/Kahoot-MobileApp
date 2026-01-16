import '../entities/question.dart';
import '../entities/answer.dart';
import '../entities/kahoot.dart';
import '../entities/category.dart';
abstract class KahootDatasource {
  Future<void> createKahoot(String kahootId, String authorId, String title, String description, String image, String visibility, String status, String theme, List<Question> quiz, List<Answer> answer);
  Future<void> updateKahoot(Kahoot kahoot);
  Future <void> deleteKahoot(String id);
  Future<List<Kahoot>> getAllKahoots();
  Future<List<Kahoot>> getKahootsByAuthor(String authorId);
  Future<Kahoot?> getKahootByKahootId(String kahootId);
  Future<List<Category>> getCategory();
}