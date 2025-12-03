import 'package:dio/dio.dart';
import 'dart:convert';
import '../../domain/datasouce/kahoot_datasource.dart';
import '../../domain/entities/kahoot.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/answer.dart';

class KahootDatasourceImpl implements KahootDatasource {
  final Dio dio = Dio();

  @override
  Future<void> createKahoot(
    String kahootId,
    String authorId,
    String title,
    String description,
    String image,
    String visibility,
    String theme,
    List<Question> question,
    List<Answer> answer,
  ) async {
    // Build body following backend contract; map empty strings to nulls where applicable
    Map<String, dynamic> body = {
      'authorId': "f1986c62-7dc1-47c5-9a1f-03d34043e8f4",
      'title': title,
      'description': description,
      'coverImageId': image.isEmpty ? null : image,
      'visibility': "private", // backend expects 'private' | 'public'
      'status': 'draft',
      'category': 'Tecnología',
      'themeId': "f1986c62-7dc1-47c5-9a1f-03d34043e8f4",
      'questions': question.map((q) => {
            'questionText': q.title,
            'mediaId': (q.mediaId.isEmpty ? null : q.mediaId),
            'questionType': _mapQuestionType(q.type),
            'timeLimit': q.timeLimitSeconds,
            'points': q.points,
            'answers': q.answer.map((a) => {
                  'answerText': (a.text.isEmpty ? null : a.text),
                  'mediaId': (a.image.isEmpty ? null : a.image),
                  'isCorrect': a.isCorrect,
                }).toList(),
          }).toList(),
    };

    // Debug: log payload to help diagnose 500s
    // ignore: avoid_print
    print('POST /kahoots payload: ' + jsonEncode(body));

    await dio.request(
      '/kahoots',
      options: Options(method: 'POST', headers: {'Content-Type': 'application/json'}),
      data: body,
    );
  }

  @override
  Future<void> updateKahoot(Kahoot kahoot) async {
    final String kahootId = kahoot.kahootId; // o el campo que uses como ID
    final Map<String, dynamic> body = {
      'authorId': "f1986c62-7dc1-47c5-9a1f-03d34043e8f4",
      'title': kahoot.title,
      'description': kahoot.description,
      'coverImageId': kahoot.image,
      'visibility': "private",
      'themeId': "f1986c62-7dc1-47c5-9a1f-03d34043e8f4",
      'questions': kahoot.question
          .map(
            (q) => {
              'questionText': q.title,
              'mediaId': q.mediaId,
              'questionType': _mapQuestionType(q.type),
              'timeLimit': q.timeLimitSeconds,
              'points': q.points,
              'answers': q.answer
                  .map(
                    (a) => {
                      'answerText': a.text,
                      'mediaId': a.image,
                      'isCorrect': a.isCorrect,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };

    await dio.put(
      '/kahoots/$kahootId',
      data: body,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
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
          validateStatus: (status) => status != null && ((status >= 200 && status < 300) || status == 404),
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
            text: (qm['questionText'] as String?) ?? '',
            title: (qm['questionText'] as String?) ?? '',
            mediaId: (qm['mediaId'] as String?) ?? '',
            type: QuestionTypeX.fromString((qm['questionType'] as String?) ?? 'quiz'),
            points: (qm['points'] as int?) ?? 0,
            timeLimitSeconds: (qm['timeLimit'] as int?) ?? 0,
            answer: answersRaw.map((a) {
              final am = a as Map<String, dynamic>;
              return Answer(
                text: (am['answerText'] as String?) ?? '',
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
          visibility: KahootVisibilityX.fromString((m['visibility'] as String?) ?? 'private'),
          question: questions,
          image: (m['coverImageId'] as String?) ?? '',
          theme: (m['themeId'] as String?) ?? '',
        );
      }).toList();
    } on DioException catch (e) {
      throw e;
    }
  }
}

String _mapQuestionType(QuestionType t) {
  switch (t) {
    case QuestionType.true_false:
      return 'true_false';
    case QuestionType.quiz_single:
    case QuestionType.quiz_multiple:
      return 'quiz';
    default:
      return 'quiz';
  }
}
