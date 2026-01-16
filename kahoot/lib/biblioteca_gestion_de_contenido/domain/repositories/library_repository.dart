import '../../../core/result.dart';
import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import '../../../Creacion_edicion_quices/domain/entities/question.dart';
import '../../../Creacion_edicion_quices/domain/entities/answer.dart';
import '../../../Creacion_edicion_quices/domain/entities/category.dart';

abstract class KahootRepository {
  Future<Result<List<Kahoot>>> getMyKahoots();
  Future<Result<void>> addKahootToFavorites(String kahootId);
  Future<Result<void>> removeKahootFromFavorites(String kahootId);
  Future<Result<void>> deleteKahoot(String kahootId);
  Future<Result<void>> updateMyKahoot(String kahootId, String title, String description, String image, String visibility, String status, String theme, List<Question> question, List<Answer> answer);
  Future<Result<List<Category>>> getCategory();
}