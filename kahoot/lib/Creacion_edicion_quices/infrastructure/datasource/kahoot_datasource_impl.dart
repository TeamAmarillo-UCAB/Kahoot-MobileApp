import 'package:dio/dio.dart';
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
    await dio.request(
      '/kahoots',
      options: Options(method: 'POST'),
      data: {
        'authorId': "f1986c62-7dc1-47c5-9a1f-03d34043e8f4",
        'title': title,
        'description': description,
        'coverImageId': image,
        'visibility': "private",
        'status': 'draft',
        'category': 'Tecnología',
        'themeId': "f1986c62-7dc1-47c5-9a1f-03d34043e8f4",
        'questions': question
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
      },
    );
  }

  @override
  Future<void> updateKahoot(Kahoot kahoot) async {
    final String kahootId = kahoot.kahootId; // o el campo que uses como ID
    final Map<String, dynamic> body = {
      'authorId': kahoot.authorId,
      'title': kahoot.title,
      'description': kahoot.description,
      'coverImageId': kahoot.image,
      'visibility': kahoot.visibility.toShortString(),
      'themeId': kahoot.theme,
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
    final response = await dio.get(
      '/kahoots',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final data = response.data;
    if (data is List) {
      return Kahoot.fromJsonList(data);
    } else if (data is Map<String, dynamic> && data['kahoots'] is List) {
      return Kahoot.fromJsonList(data['kahoots'] as List);
    } else {
      return [];
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
