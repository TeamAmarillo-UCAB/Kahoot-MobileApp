import '../../domain/repositories/kahoot_repository.dart';
import '../../domain/datasouce/kahoot_datasource.dart';
import '../../domain/entities/kahoot.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/answer.dart';
import '../../core/result.dart';


class KahootRepositoryImpl implements KahootRepository{
  final KahootDatasource datasource;

  KahootRepositoryImpl({required this.datasource});

  @override
  Future<Result<void>> createKahoot(String kahootId, String authorId, String title, String description, String image, String visibility, String theme, List<Question> question, List<Answer> answer) async {
    try {
      await datasource.createKahoot(kahootId, authorId, title, description, image, visibility, theme, question, answer);
      return Result.success(null);
    } catch (e, stackTrace) {
      print("Error creating kahoot: $e");
      print("Stacktrace: $stackTrace");
      return Result.makeError(Exception(e));
    }
  }

  @override
  Future<Result<void>> updateKahoot(Kahoot kahoot) async {
    try {
      await datasource.updateKahoot(kahoot);
      return Result.success(null);
    } catch (e, stackTrace) {
      print("Error updating kahoot: $e");
      print("Stacktrace: $stackTrace");
      return Result.makeError(Exception(e));
    }
  }

  @override
  Future<Result<void>> deleteKahoot(String id) async {
    try {
      await datasource.deleteKahoot(id);
      return Result.success(null);
    } catch (e, stackTrace) {
      print("Error deleting kahoot: $e");
      print("Stacktrace: $stackTrace");
      return Result.makeError(Exception(e));
    }
  }

  @override
  Future<Result<List<Kahoot>>> getAllKahoots() async {  
    try {
      final kahoots = await datasource.getAllKahoots();
      return Result.success(kahoots);
    } catch (e, stackTrace) {
      print("Error fetching kahoots: $e");
      print("Stacktrace: $stackTrace");
      return Result.makeError(Exception(e));
    }
  }

}