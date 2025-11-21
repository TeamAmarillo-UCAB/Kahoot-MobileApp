import 'package:dio/dio.dart';
import '../../domain/datasouce/kahoot_datasource.dart';
import '../../domain/entities/kahoot.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/answer.dart';

class KahootDatasourceImpl implements KahootDatasource{
  final Dio dio = Dio();

  @override
  Future<void> createKahoot(String kahootId, String authorId, String title, String description, String image, String visibility, String theme, List<Question> question, List<Answer> answer) async{
    await dio.request(
      'https://api',
      options: Options(method: 'POST'),
      data: {
        'authorId': authorId,
        'title': title,
        'description': description,
        'coverImageId': image,
        'visibility': visibility,
        'themeId': theme,
        'questions': question.map((q) => {
          'questionText': q.title,
          'questionType': q.type.toString(),
          'timeLimit': q.timeLimitSeconds,
          'points': q.points,
          'answers': q.answer.map((a) => {
            'answerText': a.text,
            'mediaId': a.image,
            'isCorrect': a.isCorrect,
          }).toList(),
        }).toList(),
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
      'visibility': kahoot.visibility.toString(),
      'themeId': kahoot.theme,
      'questions': kahoot.question.map((q) => {
        'questionText': q.title,
        'questionType': q.type.toString(),
        'timeLimit': q.timeLimitSeconds,
        'points': q.points,
        'answers': q.answer.map((a) => {
          'answerText': a.text,
          'mediaId': a.image,
          'isCorrect': a.isCorrect,
        }).toList(),
      }).toList(),
    };

    await dio.put(
      'https://api/kahoots/$kahootId',
      data: body,
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  @override
  Future<void> deleteKahoot(String id) async {
    await dio.delete(
      'https://api/kahoots/$id',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  @override
  Future<List<Kahoot>> getAllKahoots() async {
    final response = await dio.get(
      'https://api/kahoots',
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