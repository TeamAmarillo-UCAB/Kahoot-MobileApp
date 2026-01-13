import 'package:dio/dio.dart';
import 'dart:convert';
import '../../domain/datasouce/kahoot_datasource.dart';
import '../../domain/entities/kahoot.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/answer.dart';
import '../../../core/auth_state.dart';

class KahootDatasourceImpl implements KahootDatasource {
  final Dio dio = Dio();
  String? lastCreatedKahootId;

  KahootDatasourceImpl() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthState.token.value;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ' + token;
            // options.auth is not a valid property for RequestOptions in Dio; only set the header.
          }
          handler.next(options);
        },
      ),
    );
  }

  @override
  Future<void> createKahoot(
    String kahootId,
    String authorId,
    String title,
    String description,
    String image,
    String visibility,
    String status,
    String theme,
    List<Question> question,
    List<Answer> answer,
  ) async {
    // Validación: si el estado es "draft" la visibilidad no puede ser "public"
    final String _status = status.trim().toLowerCase();
    final String _visibility = visibility.trim().toLowerCase();
    /*if (_status == 'draft' && _visibility == 'public') {
      throw Exception('La visibilidad no puede ser pública cuando el estado es "draft".');
    }*/

    // Build body following backend contract; map empty strings to nulls where applicable
    Map<String, dynamic> body = {
      'title': title,
      'description': description,
      'coverImageId': image.isEmpty ? null : image,
      'visibility': visibility,
      'status': status,
      'category': theme,
      'themeId': '3ef13730-7081-4c9d-881a-d3755c408272',
      // 'themeId': theme.isEmpty ? null : theme,
      'questions': question.map((q) {
        final String qt = (q.title.isNotEmpty ? q.title : q.text);
        final String qMedia = q.mediaId;
        final String qType = _mapQuestionTypeV2(q.type);
        final answersMapped = q.answer.asMap().entries.map((entry) {
          final int idx = entry.key;
          final Answer a = entry.value;
          final String text = (a.text).trim();
          final String media = (a.image).trim();
          String? answerText;
          String? mediaId;
          if (text.isNotEmpty && media.isNotEmpty) {
            answerText = text;
            mediaId = null;
          } else if (text.isNotEmpty) {
            answerText = text;
            mediaId = null;
          } else if (media.isNotEmpty) {
            answerText = null;
            mediaId = media;
          } else {
            if (qType == 'true_false') {
              answerText = idx == 0 ? 'Verdadero' : 'Falso';
              mediaId = null;
            } else {
              answerText = null;
              mediaId = null;
            }
          }
          return {
            'text': answerText,
            'mediaId': mediaId,
            'isCorrect': a.isCorrect,
          };
        }).toList();

        return {
          'text': qt,
          'mediaId': qMedia.isEmpty ? null : qMedia,
          'type': qType,
          'timeLimit': q.timeLimitSeconds,
          'points': q.points,
          'answers': answersMapped,
        };
      }).toList(),
    };

    // Debug: log payload to help diagnose 500s
    // ignore: avoid_print
    print('POST /kahoots payload: ' + jsonEncode(body));

    final Response res = await dio.request(
      '/kahoots',
      options: Options(
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
      ),
      data: body,
    );
    // Mostrar respuesta del endpoint para ver el objeto creado o mensajes
    try {
      print(
        'Respuesta POST /kahoots (status ${res.statusCode}): ' +
            jsonEncode(res.data),
      );
      if (res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        lastCreatedKahootId =
            (map['kahootId'] as String?) ?? (map['id'] as String?);
      }
    } catch (_) {
      // Si no es JSON serializable, mostrar como string
      print(
        'Respuesta POST /kahoots (status ${res.statusCode}): ' +
            res.data.toString(),
      );
    }
  }

  @override
  Future<void> updateKahoot(Kahoot kahoot) async {
    final String kahootId =
        kahoot.kahootId; // utilizar el id del kahoot recibido
    // Fetch existing kahoot to preserve fields when incoming values are empty
    Kahoot? existing;
    try {
      existing = await getKahootByKahootId(kahootId);
    } catch (_) {
      existing = null;
    }
    // Keep status hardcoded as 'published' per request
    const String status = 'published';

    final Map<String, dynamic> body = {
      'title': kahoot.title.isNotEmpty
          ? kahoot.title
          : (existing?.title ?? kahoot.title),
      'description': kahoot.description.isNotEmpty
          ? kahoot.description
          : (existing?.description ?? kahoot.description),
      'coverImageId': kahoot.image.isNotEmpty
          ? kahoot.image
          : ((existing?.image ?? '').isNotEmpty ? existing!.image : null),
      'visibility': kahoot.visibility.toShortString(),
      'status': status,
      'category': kahoot.theme,
      'themeId': kahoot.theme.isNotEmpty ? kahoot.theme : null,
      // Combinar preguntas existentes y nuevas (sin duplicar por texto)
      'questions': (() {
        final List<Map<String, dynamic>> existingQuestions =
            (existing?.question
                .map(
                  (q) => {
                    'text': q.text,
                    'mediaId': q.mediaId.isNotEmpty ? q.mediaId : null,
                    'type': _mapQuestionTypeV2(q.type),
                    'timeLimit': q.timeLimitSeconds,
                    'points': q.points,
                    'answers': q.answer
                        .map(
                          (a) => {
                            'text': a.text,
                            'mediaId': a.image.isNotEmpty ? a.image : null,
                            'isCorrect': a.isCorrect,
                          },
                        )
                        .toList(),
                  },
                )
                .toList() ??
            []);
        final List<Map<String, dynamic>> newQuestions = kahoot.question
            .asMap()
            .entries
            .map((entry) {
              final int qIdx = entry.key;
              final Question q = entry.value;
              final Question? exQ =
                  (existing != null && existing.question.length > qIdx)
                  ? existing.question[qIdx]
                  : null;
              final String qtCandidate = q.text.isNotEmpty
                  ? q.text
                  : (q.title.isNotEmpty ? q.title : '');
              final String qt = qtCandidate.isNotEmpty
                  ? qtCandidate
                  : ((exQ?.text ?? exQ?.title ?? ''));
              final String qMedia = q.mediaId;
              final String qType = _mapQuestionTypeV2(q.type);
              final answersMappedAll = q.answer.asMap().entries.map((aEntry) {
                final int idx = aEntry.key;
                final Answer a = aEntry.value;
                final Answer? exA = (exQ != null && exQ.answer.length > idx)
                    ? exQ.answer[idx]
                    : null;
                final String text = a.text.trim();
                final String media = a.image.trim();
                String? answerText;
                String? mediaId;
                if (text.isNotEmpty && media.isNotEmpty) {
                  answerText = text;
                  mediaId = null;
                } else if (text.isNotEmpty) {
                  answerText = text;
                  mediaId = null;
                } else if (media.isNotEmpty) {
                  answerText = null;
                  mediaId = media;
                } else {
                  if (qType == 'true_false') {
                    answerText = idx == 0 ? 'Verdadero' : 'Falso';
                    mediaId = null;
                  } else {
                    final String exText = (exA?.text ?? '').trim();
                    final String exMedia = (exA?.image ?? '').trim();
                    if (exText.isNotEmpty) {
                      answerText = exText;
                      mediaId = null;
                    } else if (exMedia.isNotEmpty) {
                      answerText = null;
                      mediaId = exMedia;
                    } else {
                      answerText = null;
                      mediaId = null;
                    }
                  }
                }
                return {
                  'text': answerText,
                  'mediaId': mediaId,
                  'isCorrect': a.isCorrect,
                };
              }).toList();
              final answersMapped = answersMappedAll
                  .where((a) => a['text'] != null || a['mediaId'] != null)
                  .toList();
              print(
                'Pregunta #' +
                    qIdx.toString() +
                    ' text="' +
                    (qt) +
                    '" respuestas_validas=' +
                    answersMapped.length.toString(),
              );
              return {
                'text': qt,
                'mediaId': qMedia.isNotEmpty
                    ? qMedia
                    : (((exQ?.mediaId ?? '')).isNotEmpty ? exQ!.mediaId : null),
                'type': qType,
                'timeLimit': q.timeLimitSeconds,
                'points': q.points,
                'answers': answersMapped,
              };
            })
            // Omitir preguntas sin texto luego del merge
            .where(
              (qMap) => ((qMap['text'] as String?) ?? '').trim().isNotEmpty,
            )
            .toList();
        // Combinar sin duplicar por texto
        final Set<String> seenTexts = {};
        final List<Map<String, dynamic>> combined = [];
        for (final q in [...existingQuestions, ...newQuestions]) {
          final t = (q['text'] as String?)?.trim() ?? '';
          if (t.isNotEmpty && !seenTexts.contains(t)) {
            seenTexts.add(t);
            combined.add(q);
          }
        }
        return combined;
      })(),
    };

    // Debug: log PUT payload before sending
    // ignore: avoid_print
    print('PUT /kahoots/' + kahootId + ' payload: ' + jsonEncode(body));

    final Response res = await dio.put(
      '/kahoots/$kahootId',
      data: body,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    // Mostrar respuesta del endpoint para validar el update
    try {
      print(
        'Respuesta PUT /kahoots/$kahootId (status ${res.statusCode}): ' +
            jsonEncode(res.data),
      );
    } catch (_) {
      print(
        'Respuesta PUT /kahoots/$kahootId (status ${res.statusCode}): ' +
            res.data.toString(),
      );
    }
  }

  @override
  Future<void> deleteKahoot(String id) async {
    await dio.delete(
      '/kahoots/$id',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  @override
  Future<List<Kahoot>> getAllKahoots() async {
    try {
      final response = await dio.get(
        '/kahoots',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) =>
              status != null &&
              ((status >= 200 && status < 300) || status == 404),
        ),
      );
      if (response.statusCode == 404) {
        return [];
      }
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic> && data['kahoots'] is List) {
        list = data['kahoots'] as List;
      } else {
        list = const [];
      }

      // Map backend schema -> domain schema
      return list.map((raw) {
        final m = raw as Map<String, dynamic>;
        final questionsRaw = (m['questions'] as List?) ?? const [];
        final questions = questionsRaw.map((q) {
          final qm = q as Map<String, dynamic>;
          final answersRaw = (qm['answers'] as List?) ?? const [];
          return Question(
            text: (qm['text'] as String?) ?? '',
            title: (qm['text'] as String?) ?? '',
            mediaId: (qm['mediaId'] as String?) ?? '',
            type: QuestionTypeX.fromString(
              (qm['type'] as String?) ?? 'quiz_single',
            ),
            points: (qm['points'] as int?) ?? 0,
            timeLimitSeconds: (qm['timeLimit'] as int?) ?? 0,
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

        return Kahoot(
          kahootId: '',
          authorId: '',
          title: (m['title'] as String?) ?? '',
          description: (m['description'] as String?) ?? '',
          visibility: KahootVisibilityX.fromString(
            (m['visibility'] as String?) ?? 'private',
          ),
          question: questions,
          image: (m['coverImageId'] as String?) ?? '',
          theme: (m['themeId'] as String?) ?? '',
        );
      }).toList();
    } on DioException catch (e) {
      throw e;
    }
  }

  Future<List<Kahoot>> getKahootsByAuthor(String userId) async {
    try {
      final response = await dio.get(
        '/kahoots/userId',
        queryParameters: {'userId': userId},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) =>
              status != null &&
              ((status >= 200 && status < 300) || status == 404),
        ),
      );
      if (response.statusCode == 404) {
        return [];
      }
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic>) {
        final candidates = ['kahoots', 'items', 'content', 'data', 'results'];
        final foundKey = candidates.firstWhere(
          (k) => data[k] is List,
          orElse: () => '',
        );
        list = foundKey.isNotEmpty ? (data[foundKey] as List) : const [];
      } else {
        list = const [];
      }
      return list.map((raw) {
        final m = raw as Map<String, dynamic>;
        final questionsRaw = (m['questions'] as List?) ?? const [];
        final questions = questionsRaw.map((q) {
          final qm = q as Map<String, dynamic>;
          final answersRaw = (qm['answers'] as List?) ?? const [];
          return Question(
            text: (qm['text'] as String?) ?? '',
            title: (qm['text'] as String?) ?? '',
            mediaId: (qm['mediaId'] as String?) ?? '',
            type: QuestionTypeX.fromString(
              (qm['questionType'] as String?) ?? 'quiz',
            ),
            points: (qm['points'] as int?) ?? 0,
            timeLimitSeconds: (qm['timeLimit'] as int?) ?? 0,
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
        return Kahoot(
          kahootId: (m['kahootId'] as String?) ?? (m['id'] as String? ?? ''),
          authorId: (m['authorId'] as String?) ?? '',
          title: (m['title'] as String?) ?? '',
          description: (m['description'] as String?) ?? '',
          visibility: KahootVisibilityX.fromString(
            (m['visibility'] as String?) ?? 'private',
          ),
          question: questions,
          image: (m['coverImageId'] as String?) ?? '',
          theme: (m['themeId'] as String?) ?? '',
        );
      }).toList();
    } on DioException catch (e) {
      throw e;
    }
  }

  Future<Kahoot?> getKahootByKahootId(String kahootId) async {
    try {
      final response = await dio.get(
        '/kahoots/$kahootId',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) =>
              status != null &&
              ((status >= 200 && status < 300) || status == 404),
        ),
      );
      if (response.statusCode == 404) {
        return null;
      }
      final m = response.data as Map<String, dynamic>;
      final questionsRaw = (m['questions'] as List?) ?? const [];
      final questions = questionsRaw.map((q) {
        final qm = q as Map<String, dynamic>;
        final answersRaw = (qm['answers'] as List?) ?? const [];
        return Question(
          text: (qm['text'] as String?) ?? '',
          title: (qm['text'] as String?) ?? '',
          mediaId: (qm['mediaId'] as String?) ?? '',
          type: QuestionTypeX.fromString(
            (qm['questionType'] as String?) ?? 'quiz',
          ),
          points: (qm['points'] as int?) ?? 0,
          timeLimitSeconds: (qm['timeLimit'] as int?) ?? 0,
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
      return Kahoot(
        kahootId: (m['kahootId'] as String?) ?? (m['id'] as String? ?? ''),
        authorId: (m['authorId'] as String?) ?? '',
        title: (m['title'] as String?) ?? '',
        description: (m['description'] as String?) ?? '',
        visibility: KahootVisibilityX.fromString(
          (m['visibility'] as String?) ?? 'private',
        ),
        question: questions,
        image: (m['coverImageId'] as String?) ?? '',
        theme: (m['themeId'] as String?) ?? '',
      );
    } on DioException catch (e) {
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getThemes() async {
    try {
      final response = await dio.get('/media/themes');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      throw Exception('Error al obtener temas: $e');
    }
  }
}

String _mapQuestionTypeV2(QuestionType t) {
  switch (t) {
    case QuestionType.true_false:
      return 'true_false';
    case QuestionType.quiz_single:
      return 'single';
    case QuestionType.quiz_multiple:
      return 'multiple';
    default:
      return 'single';
  }
}
