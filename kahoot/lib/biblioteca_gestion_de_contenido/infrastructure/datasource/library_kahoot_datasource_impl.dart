import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import '../../domain/datasource/library_datasource.dart';
import '../../../core/auth_state.dart';

class LibraryKahootDatasourceImpl implements LibraryDatasource {
	final Dio dio = Dio();

	LibraryKahootDatasourceImpl() {
		dio.interceptors.add(
			InterceptorsWrapper(onRequest: (options, handler) {
				final token = AuthState.token.value;
				if (token != null && token.isNotEmpty) {
					options.headers['Authorization'] = 'Bearer ' + token;
				}
				handler.next(options);
			}),
		);
	}

	@override
	Future<List<Kahoot>> getMyKahoots() async {
		final token = AuthState.token.value;
		print('[LIBRARY] Token usado para Authorization: ' + (token ?? 'NULL'));
		final headers = {'Content-Type': 'application/json'};
		if (token != null && token.isNotEmpty) {
			headers['Authorization'] = 'Bearer ' + token;
		} else {
			print('[LIBRARY] ¡Advertencia! El token está vacío o nulo al hacer getMyKahoots');
		}
		final Response res = await dio.get(
			'/library/my-creations',
			options: Options(headers: headers),
		);
		// Log for debugging
		try {
			print('GET /library/my-creations (status ${res.statusCode}) -> ' + jsonEncode(res.data));
		} catch (_) {
			print('GET /library/my-creations (status ${res.statusCode}) -> ' + res.data.toString());
		}

		final data = res.data;
		if (data is List) {
			return Kahoot.fromJsonList(data.cast<Map<String, dynamic>>());
		} else if (data is Map<String, dynamic>) {
			final list = (data['data'] as List?) ?? (data['items'] as List?) ?? (data['results'] as List?) ?? const [];
			return Kahoot.fromJsonList(list.cast<Map<String, dynamic>>());
		}
		return const <Kahoot>[];
	}
}
