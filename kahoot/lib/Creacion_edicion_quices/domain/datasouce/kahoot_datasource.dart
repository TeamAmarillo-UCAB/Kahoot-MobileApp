import '../entities/question.dart';
import '../entities/answer.dart';
import '../entities/kahoot.dart';
abstract class KahootDatasource {
  Future<void> createKahoot(String kahootId, String authorId, String title, String description, String image, String visibility, String theme, List<Question> quiz, List<Answer> answer);
  Future<void> updateKahoot(Kahoot kahoot);
  Future <void> deleteKahoot(String id);
  Future<List<Kahoot>> getAllKahoots();
}