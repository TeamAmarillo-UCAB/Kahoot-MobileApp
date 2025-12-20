import 'package:dio/dio.dart';
import '../../domain/datasource/game_datasource.dart';
import '../../domain/entities/attempt.dart';
import '../../domain/entities/game_summary.dart';

class GameDatasourceImpl implements GameDatasource {
  final Dio dio = Dio();

  @override
  Future<Attempt> startAttempt(String kahootId) async {
    // POST /attempts -> Crea un nuevo intento de juego solo
    final response = await dio.post('/attempts', data: {'kahootId': kahootId});
    return Attempt.fromJson(response.data);
  }

  @override
  Future<Attempt> getAttemptStatus(String attemptId) async {
    // GET /attempts/{id} -> Recupera el estado actual
    final response = await dio.get('/attempts/$attemptId');
    return Attempt.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> submitAnswer({
    required String attemptId,
    required String slideId,
    required List<int> answerIndex,
    required int timeElapsedSeconds,
    String? textAnswer,
  }) async {
    // POST /attempts/{id}/answer -> Envía la respuesta
    // El cuerpo incluye los índices para Quiz/TF y el texto para Short Answer
    final response = await dio.post(
      '/attempts/$attemptId/answer',
      data: {
        'slideId': slideId,
        'answerIndex': answerIndex,
        'timeElapsedSeconds': timeElapsedSeconds,
        if (textAnswer != null) 'textAnswer': textAnswer,
      },
    );

    // Retornamos el mapa crudo porque contiene datos mezclados
    // (wasCorrect, points, nextSlide, etc.)
    return response.data;
  }

  @override
  Future<GameSummary> getSummary(String attemptId) async {
    // GET /attempts/{id}/summary -> Resultados finales
    final response = await dio.get('/attempts/$attemptId/summary');
    return GameSummary.fromJson(response.data);
  }
}
