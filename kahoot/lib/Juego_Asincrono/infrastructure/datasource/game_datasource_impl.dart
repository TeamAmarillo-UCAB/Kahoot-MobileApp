import 'package:dio/dio.dart';
import '../../domain/datasource/game_datasource.dart';
import '../../domain/entities/attempt.dart';
import '../../domain/entities/game_summary.dart';
import '../../../core/auth_state.dart';
import '../../../config/api_config.dart';

class GameDatasourceImpl implements GameDatasource {
  final Dio dio;

  GameDatasourceImpl({Dio? dio})
    : this.dio =
          dio ??
          Dio(BaseOptions(headers: {'Content-Type': 'application/json'})) {
    // Interceptor para el header
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthState.token.value;
          options.baseUrl = ApiConfig().baseUrl;
          /*const String jwtToken =
              // JWT HARDCODEADO CAMBIARRRRRRRR
              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjdhYmM2ZmVkLTY2NWUtNDYzZC1iNTRkLThkNzhjMTM5N2U2ZiIsImVtYWlsIjoibmNhcmxvc0BleGFtcGxlLmNvbSIsInJvbGVzIjpbInVzZXIiXSwiaWF0IjoxNzY4MDIwMTAxLCJleHAiOjE3NjgwMjczMDF9.AEIywEWaRYQDvso5lzOgGp-2oMMXAVgs65vhK3YIQ90";
          */
          // Inyección de userId como header
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
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
