import 'package:dio/dio.dart';
import '../../domain/datasource/game_datasource.dart';
import '../../domain/entities/attempt.dart';
import '../../domain/entities/game_summary.dart';

class GameDatasourceImpl implements GameDatasource {
  final Dio dio;

  GameDatasourceImpl({Dio? dio})
    : this.dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://quizzy-backend-0wh2.onrender.com/api',
              headers: {'Content-Type': 'application/json'},
            ),
          );

  @override
  Future<Map<String, dynamic>> submitAnswer({
    required String attemptId,
    required String slideId,
    required List<int> answerIndex,
    required int timeElapsedSeconds,
    String? textAnswer,
  }) async {
    final response = await dio.post(
      '/attempts/$attemptId/answer',
      data: {
        'slideId': slideId,
        'answerIndex': answerIndex,
        'timeElapsedSeconds': timeElapsedSeconds,
        if (textAnswer != null) 'textAnswer': textAnswer,
      },
    );
    return response.data;
  }

  @override
  Future<Attempt> startAttempt(String kahootId) async {
    final response = await dio.post('/attempts', data: {'kahootId': kahootId});
    return Attempt.fromJson(response.data);
  }

  @override
  Future<GameSummary> getSummary(String attemptId) async {
    final response = await dio.get('/attempts/$attemptId/summary');
    return GameSummary.fromJson(response.data);
  }

  @override
  Future<Attempt> getAttemptStatus(String attemptId) async {
    final response = await dio.get('/attempts/$attemptId');
    return Attempt.fromJson(response.data);
  }
}
