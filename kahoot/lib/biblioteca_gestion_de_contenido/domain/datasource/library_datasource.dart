import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import '../../../Creacion_edicion_quices/domain/entities/question.dart';
import '../../../Creacion_edicion_quices/domain/entities/answer.dart';
import '../../../Creacion_edicion_quices/domain/entities/category.dart';

abstract class LibraryDatasource {
  Future<List<Kahoot>> getMyKahoots();
  Future<void> addKahootToFavorites(String kahootId);
  Future<void> removeKahootFromFavorites(String kahootId);
  Future<void> deleteKahoot(String kahootId);
  Future<void> updateMyKahoot(String kahootId, String title, String description, String image, String visibility, String status, String theme, List<Question> question, List<Answer> answer);
  Future<List<Category>> getCategory();
}