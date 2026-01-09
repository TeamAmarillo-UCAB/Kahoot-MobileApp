import '../../domain/repositories/library_repository.dart';
import '../../domain/datasource/library_datasource.dart';
import '../../../core/result.dart';
import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';

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
}
