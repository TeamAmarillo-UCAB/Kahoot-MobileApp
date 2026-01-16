import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import '../../../Creacion_edicion_quices/domain/entities/question.dart';
import '../../../Creacion_edicion_quices/domain/entities/answer.dart';
import '../../../Creacion_edicion_quices/domain/entities/category.dart';
import '../../domain/datasource/library_datasource.dart';
import '../../../core/auth_state.dart';

class LibraryKahootDatasourceImpl implements LibraryDatasource {
  final Dio dio = Dio();

  LibraryKahootDatasourceImpl() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthState.token.value;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ' + token;
          }
          handler.next(options);
        },
      ),
    );
  }

  @override
  Future<List<Category>> getCategory() async {
    final token = AuthState.token.value;
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer ' + token;
    }
    final Response res = await dio.get(
      '/explore/categories',
      options: Options(headers: headers),
    );
    final data = res.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      final candidates = ['categories', 'items', 'content', 'data', 'results'];
      final foundKey = candidates.firstWhere(
        (k) => data[k] is List,
        orElse: () => '',
      );
      list = foundKey.isNotEmpty ? (data[foundKey] as List) : const [];
    } else {
      list = const [];
    }
    return list.map((raw) {
      if (raw is String) {
        return Category(nombre: raw);
      }
      if (raw is Map<String, dynamic>) {
        return Category.fromJson(raw);
      }
      return Category(nombre: raw.toString());
    }).toList();
  }

  @override
  Future<List<Kahoot>> getMyKahoots() async {
    final token = AuthState.token.value;
    print('[LIBRARY] Token usado para Authorization: ' + (token ?? 'NULL'));
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer ' + token;
    } else {
      print(
        '[LIBRARY] ¡Advertencia! El token está vacío o nulo al hacer getMyKahoots',
      );
    }
    final Response res = await dio.get(
      '/library/my-creations',
      options: Options(headers: headers),
    );
    // Log for debugging
    try {
      print(
        'GET /library/my-creations (status ${res.statusCode}) -> ' +
            jsonEncode(res.data),
      );
    } catch (_) {
      print(
        'GET /library/my-creations (status ${res.statusCode}) -> ' +
            res.data.toString(),
      );
    }

    final data = res.data;

    QuestionType _parseType(String? raw) {
      final v = (raw ?? 'single').toLowerCase().replaceAll(' ', '_');
      if (v == 'multiple' || v == 'quiz_multiple' || v == 'quiz') return QuestionType.quiz_multiple;
      if (v == 'single' || v == 'quiz_single') return QuestionType.quiz_single;
      if (v == 'true_false' || v == 'true_or_false') return QuestionType.true_false;
      if (v == 'short_answer') return QuestionType.short_answer;
      return QuestionType.quiz_single;
    }

    List<Kahoot> _mapList(List<Map<String, dynamic>> rawList) {
      return rawList.map((raw) {
        final m = Map<String, dynamic>.from(raw);
        final id = (m['kahootId'] ?? m['id'] ?? m['_id'] ?? '').toString();
        final questionsRaw = (m['questions'] as List?) ?? const [];
        final questions = questionsRaw.map((q) {
          final qm = q as Map<String, dynamic>;
          final answersRaw = (qm['answers'] as List?) ?? const [];
          return Question(
            text: (qm['text'] as String?) ?? '',
            title: (qm['title'] as String?) ?? (qm['text'] as String?) ?? '',
            mediaId: (qm['mediaId'] as String?) ?? '',
            type: _parseType((qm['questionType'] as String?) ?? (qm['type'] as String?)),
            points: (qm['points'] as int?) ?? 0,
            timeLimitSeconds: (qm['timeLimitSeconds'] as int?) ?? (qm['timeLimit'] as int?) ?? 0,
            answer: answersRaw.map((a) {
              final am = a as Map<String, dynamic>;
              return Answer(
                text: (am['text'] as String?) ?? '',
                image: (am['mediaId'] as String?) ?? '',
                isCorrect: (am['isCorrect'] as bool?) ?? false,
                questionId: '',
              );
            }).toList(),
          );
        }).toList();
        final String themeValue = ((m['category'] ?? m['theme'] ?? m['themeName'] ?? m['themeId']) as String?) ?? '';
        return Kahoot(
          kahootId: id,
          authorId: (m['authorId'] as String?) ?? '',
          title: (m['title'] as String?) ?? '',
          description: (m['description'] as String?) ?? '',
          visibility: KahootVisibilityX.fromString((m['visibility'] as String?) ?? 'private'),
          question: questions,
          image: (m['coverImageId'] as String?) ?? (m['image'] as String?) ?? '',
          theme: themeValue,
        );
      }).toList();
    }

    if (data is List) {
      final rawList = data.cast<Map<String, dynamic>>();
      final list = _mapList(rawList);
      for (final k in list) {
        print('[LIBRARY] kahootId: ' + k.kahootId);
      }
      return list;
    } else if (data is Map<String, dynamic>) {
      final list =
          (data['data'] as List?) ??
          (data['items'] as List?) ??
          (data['results'] as List?) ??
          const [];
      final rawList = list.cast<Map<String, dynamic>>();
      final mapped = _mapList(rawList);
      for (final k in mapped) {
        print('[LIBRARY] kahootId: ' + k.kahootId);
      }
      return mapped;
    }
    return const <Kahoot>[];
  }

  @override
  Future<void> addKahootToFavorites(String kahootId) async {
    final token = AuthState.token.value;
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer ' + token;
    }
    final String path = '/library/favorites/' + kahootId;
    final res = await dio.post(
      path,
      data: {'kahootId': kahootId},
      options: Options(headers: headers),
    );
    // Optional logging
    print('POST ' + path + ' -> ' + (res.statusCode?.toString() ?? ''));
  }

  @override
  Future<void> removeKahootFromFavorites(String kahootId) async {
    final token = AuthState.token.value;
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer ' + token;
    }
    final String path = '/library/favorites/' + kahootId;
    final res = await dio.delete(path, options: Options(headers: headers));
    print('DELETE ' + path + ' -> ' + (res.statusCode?.toString() ?? ''));
  }

  @override
  Future<void> deleteKahoot(String kahootId) async {
    final token = AuthState.token.value;
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer ' + token;
    }
    final String path = '/kahoots/' + kahootId;
    final res = await dio.delete(path, options: Options(headers: headers));
    print('DELETE ' + path + ' -> ' + (res.statusCode?.toString() ?? ''));
  }

  @override
  Future<void> updateMyKahoot(
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
    final token = AuthState.token.value;
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer ' + token;
    }

    String _mapType(QuestionType t) {
      switch (t) {
        case QuestionType.true_false:
          return 'true_false';
        case QuestionType.quiz_multiple:
          return 'multiple';
        case QuestionType.quiz_single:
        default:
          return 'single';
      }
    }

    final body = {
      'title': title,
      'description': description,
      'coverImageId': image.isNotEmpty ? image : null,
      'visibility': visibility,
      'status': 'draft',
      'category': theme,
      //'themeId': theme.isNotEmpty ? theme : null,
      'themeId': 'd67b732b-020b-4776-996c-98bbdaa7c263',
      'questions': question.map((q) {
        final qType = _mapType(q.type);
        return {
          'text': q.text.isNotEmpty ? q.text : q.title,
          'mediaId': q.mediaId.isNotEmpty ? q.mediaId : null,
          'type': qType,
          'timeLimit': q.timeLimitSeconds,
          'points': q.points,
          'answers': q.answer.map((a) => {
                'text': a.text.isNotEmpty ? a.text : null,
                'mediaId': a.image.isNotEmpty ? a.image : null,
                'isCorrect': a.isCorrect,
              }).where((m) => m['text'] != null || m['mediaId'] != null).toList(),
        };
      }).toList(),
    };

    print('PUT /kahoots/' + kahootId + ' payload: ' + jsonEncode(body));
    final res = await dio.put(
      '/kahoots/' + kahootId,
      options: Options(headers: headers),
      data: body,
    );
    print('PUT /kahoots/' + kahootId + ' -> ' + (res.statusCode?.toString() ?? ''));
  }
}
