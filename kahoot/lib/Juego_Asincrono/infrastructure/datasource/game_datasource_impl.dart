import 'package:dio/dio.dart';
import '../../domain/datasource/game_datasource.dart';
import '../../domain/entities/attempt.dart';
import '../../domain/entities/game_summary.dart';

class GameDatasourceImpl implements GameDatasource {
  final Dio dio;

  // Constructor que permite inyectar Dio (útil para configurar la baseUrl en el main)
  GameDatasourceImpl({Dio? dio}) : this.dio = dio ?? Dio();

  @override
  Future<Attempt> startAttempt(String kahootId) async {
    // POST /attempts -> Inicia una nueva sesión de juego solo.
    // El backend devuelve el objeto Attempt con el 'firstSlide',
    // 'playerName', 'totalQuestions' y 'currentQuestionNumber': 1.
    final response = await dio.post('/attempts', data: {'kahootId': kahootId});

    return Attempt.fromJson(response.data);
  }

  @override
  Future<Attempt> getAttemptStatus(String attemptId) async {
    // GET /attempts/{id} -> Recupera el estado actual en caso de reconexión.
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
    // POST /attempts/{id}/answer -> Envía la respuesta del usuario.
    // El cuerpo incluye los índices seleccionados o el texto para respuestas cortas.
    final response = await dio.post(
      '/attempts/$attemptId/answer',
      data: {
        'slideId': slideId,
        'answerIndex': answerIndex,
        'timeElapsedSeconds': timeElapsedSeconds,
        if (textAnswer != null) 'textAnswer': textAnswer,
      },
    );

    // Retornamos el mapa crudo porque el Repository lo usará para
    // crear el nuevo objeto Attempt que contiene el feedback ("Skill issue", etc)
    // y el 'nextSlide' para la siguiente pregunta.
    return response.data;
  }

  @override
  Future<GameSummary> getSummary(String attemptId) async {
    // GET /attempts/{id}/summary -> Obtiene los resultados finales al terminar.
    final response = await dio.get('/attempts/$attemptId/summary');
    return GameSummary.fromJson(response.data);
  }
}
