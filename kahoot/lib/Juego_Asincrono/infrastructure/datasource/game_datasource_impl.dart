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
          ) {
    // Interceptor para el header
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          const String jwtToken =
              // JWT HARDCODEADO CAMBIARRRRRRRR
              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjdhYmM2ZmVkLTY2NWUtNDYzZC1iNTRkLThkNzhjMTM5N2U2ZiIsImVtYWlsIjoibmNhcmxvc0BleGFtcGxlLmNvbSIsInJvbGVzIjpbInVzZXIiXSwiaWF0IjoxNzY3OTg1MDE3LCJleHAiOjE3Njc5OTIyMTd9.AMhPYrzGeSZjUSLMGvJtsnQ93cZByLaNQEQU_u-3AGk";

          // Inyección de userId como header
          options.headers['Authorization'] = 'Bearer $jwtToken';

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

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
