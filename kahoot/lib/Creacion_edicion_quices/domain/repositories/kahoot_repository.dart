import '../entities/question.dart';
import '../entities/answer.dart';
import '../entities/kahoot.dart';
import '../entities/category.dart';
import '../../../core/result.dart';

abstract class KahootRepository {
  Future<Result<void>> createKahoot(String kahootId, String authorId, String title, String description, String image, String visibility, String status, String theme, List<Question> question, List<Answer> answer);
  Future<Result<void>> updateKahoot(Kahoot kahoot);
  Future<Result<void>> deleteKahoot(String id);
  Future<Result<List<Kahoot>>> getAllKahoots();
  Future<Result<List<Kahoot>>> getKahootsByAuthor(String authorId);
  Future<Result<Kahoot?>> getKahootByKahootId(String kahootId);
  Future<Result<List<Category>>> getCategory();
}