import '../../domain/datasource/explore_datasource.dart';
import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../core/auth_state.dart';
import '../../../main.dart';
import '../../domain/entities/category.dart';
import '../../../config/api_config.dart';

class ExploreDatasourceImpl implements ExploreDatasource {
  final Dio dio = Dio();
  final List<String> categories = <String>[];

  ExploreDatasourceImpl() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthState.token.value;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ' + token;
          }
          options.headers['Content-Type'] = 'application/json';
          handler.next(options);
        },
      ),
    );
    dio.options.baseUrl = ApiConfig().baseUrl.trim();
  }

  // Map common English category names to Spanish equivalents.
  // If a name is already Spanish, it will be normalized below.
  static const Map<String, String> _enToEs = {
    'Art': 'Arte',
    'Biology': 'Biologia',
    'Chemistry': 'Quimica',
    'Computer Science': 'Informatica',
    'Economics': 'Economia',
    'General Knowledge': 'Cultura General',
    'Mathematics': 'Matematica',
    'Math': 'Matematica',
    'Sciences': 'Ciencias',
    'Science': 'Ciencias',
    'History': 'Historia',
    'Movies': 'Peliculas',
    'Trivia': 'Trivia',
    'Music': 'Musica',
    'Sports': 'Deportes',
    'Flags': 'Banderas',
    'Food': 'Comida',
    'Holidays': 'Festividades',
    'Animals': 'Animales',
    'Riddles': 'Adivinanzas',
    'Geography': 'Geografia',
  };

  // Remove accents and spaces, convert to TitleCase without spaces (CulturaGeneral).
  String _toSpanishSlug(String name) {
    final trimmed = name.trim();
    final spanish = _enToEs[trimmed] ?? trimmed;
    String s = spanish
        .replaceAll(RegExp(r'[áÁ]'), 'a')
        .replaceAll(RegExp(r'[éÉ]'), 'e')
        .replaceAll(RegExp(r'[íÍ]'), 'i')
        .replaceAll(RegExp(r'[óÓ]'), 'o')
        .replaceAll(RegExp(r'[úÚ]'), 'u')
        .replaceAll(RegExp(r'[üÜ]'), 'u')
        .replaceAll(RegExp(r'[ñÑ]'), 'n');
    // Normalize whitespace to single spaces
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    // TitleCase and remove spaces
    final parts = s.split(' ');
    final title = parts
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
        .join('');
    return title; // e.g., CulturaGeneral, Matematica
  }

  @override
  Future<List<Category>> getCategories() async {
    final Response res = await dio.get('/explore/categories');
    // Log for debugging
    try {
      print(
        'GET /explore/categories (status ${res.statusCode}) -> ' +
            jsonEncode(res.data),
      );
    } catch (_) {
      print(
        'GET /explore/categories (status ${res.statusCode}) -> ' +
            res.data.toString(),
      );
    }

    final data = res.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      list = (data['data'] as List?) ?? (data['items'] as List?) ?? const [];
    } else {
      list = const [];
    }
    return list
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Kahoot>> getKahootsByCategory(String category) async {
    final cats = category
        .split(',')
        .map((e) => _toSpanishSlug(e))
        .where((e) => e.isNotEmpty)
        .join(',');
    final res = await dio.get(
      '/explore',
      queryParameters: {'categories': cats},
    );
    try {
      print('GET /explore?categories=' + cats + ' (status ${res.statusCode})');
    } catch (_) {}

    final data = res.data;
    if (data is List) {
      return Kahoot.fromJsonList(data);
    }
    if (data is Map<String, dynamic>) {
      final list =
          (data['data'] as List?) ??
          (data['items'] as List?) ??
          (data['results'] as List?) ??
          const [];
      return Kahoot.fromJsonList(list);
    }
    return const <Kahoot>[];
  }
}
