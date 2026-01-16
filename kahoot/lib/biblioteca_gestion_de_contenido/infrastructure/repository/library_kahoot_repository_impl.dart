import '../../domain/repositories/library_repository.dart';
import '../../domain/datasource/library_datasource.dart';
import '../../../core/result.dart';
import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import '../../../Creacion_edicion_quices/domain/entities/question.dart';
import '../../../Creacion_edicion_quices/domain/entities/answer.dart';
import '../../../Creacion_edicion_quices/domain/entities/category.dart';

class LibraryKahootRepositoryImpl implements KahootRepository {
	final LibraryDatasource datasource;

	LibraryKahootRepositoryImpl({required this.datasource});

	@override
	Future<Result<List<Kahoot>>> getMyKahoots() async {
		try {
			final list = await datasource.getMyKahoots();
			return Result.success(list);
		} catch (e, st) {
			print('Error getMyKahoots: ' + e.toString());
			print('Stack: ' + st.toString());
			return Result.makeError(Exception(e));
		}
	}

	@override
	Future<Result<void>> addKahootToFavorites(String kahootId) async {
		try {
			await datasource.addKahootToFavorites(kahootId);
			return Result.success(null);
		} catch (e, st) {
			print('Error addKahootToFavorites($kahootId): ' + e.toString());
			print('Stack: ' + st.toString());
			return Result.makeError(Exception(e));
		}
	}

	@override
	Future<Result<void>> removeKahootFromFavorites(String kahootId) async {
		try {
			await datasource.removeKahootFromFavorites(kahootId);
			return Result.success(null);
		} catch (e, st) {
			print('Error removeKahootFromFavorites($kahootId): ' + e.toString());
			print('Stack: ' + st.toString());
			return Result.makeError(Exception(e));
		}
	}

  @override
  Future<Result<void>> deleteKahoot(String kahootId) async {
    try {
      await datasource.deleteKahoot(kahootId);
      return Result.success(null);
    } catch (e, st) {
      print('Error deleteKahoot($kahootId): ' + e.toString());
      print('Stack: ' + st.toString());
      return Result.makeError(Exception(e));
    }
  }

  @override
  Future<Result<void>> updateMyKahoot(
    String kahootId,
    String title,
    String description,
    String image,
    String visibility,
    String status,
    String theme,
    List<Question> question,
    List<Answer> answer,
  ) async {
    try {
      await datasource.updateMyKahoot(kahootId, title, description, image, visibility, status, theme, question, answer);
      return Result.success(null);
    } catch (e, st) {
      print('Error updateMyKahoot($kahootId): ' + e.toString());
      print('Stack: ' + st.toString());
      return Result.makeError(Exception(e));
    }
  }

	@override
	Future<Result<List<Category>>> getCategory() async {
		try {
			final list = await datasource.getCategory();
			return Result.success(list);
		} catch (e, st) {
			print('Error getCategory: ' + e.toString());
			print('Stack: ' + st.toString());
			return Result.makeError(Exception(e));
		}
	}
}
