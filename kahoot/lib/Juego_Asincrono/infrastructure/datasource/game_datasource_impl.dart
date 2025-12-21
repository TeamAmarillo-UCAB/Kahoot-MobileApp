import 'package:dio/dio.dart';
import '../../domain/datasource/game_datasource.dart';
import '../../domain/entities/attempt.dart';
import '../../domain/entities/game_summary.dart';

class GameDatasourceImpl implements GameDatasource {
  final Dio dio;
  GameDatasourceImpl({Dio? dio}) : this.dio = dio ?? Dio();

  @override
  Future<Attempt> startAttempt(String kahootId) async {
    // --- LÓGICA MOCK ---
    await Future.delayed(const Duration(seconds: 1));

    return Attempt.fromJson({
      "id": "mock-attempt-123",
      "playerName": "Tester Pro",
      "currentScore": 0,
      "attemptState": "IN_PROGRESS",
      "totalQuestions": 2,
      "currentQuestionNumber": 1,
      "firstSlide": {
        "id": "slide-1",
        "questionType": "quiz_single",
        "questionText": "Pregunta 1: ¿Cuál es el lenguaje de Flutter?",
        "options": [
          {"index": 0, "text": "Dart"},
          {"index": 1, "text": "Java"},
          {"index": 2, "text": "Python"},
          {"index": 3, "text": "C#"},
        ],
      },
    });

    /* // --- FUNCIÓN ORIGINAL API ---
    final response = await dio.post('/attempts', data: {'kahootId': kahootId});
    return Attempt.fromJson(response.data);
    */
  }

  @override
  Future<Map<String, dynamic>> submitAnswer({
    required String attemptId,
    required String slideId,
    required List<int> answerIndex,
    required int timeElapsedSeconds,
    String? textAnswer,
  }) async {
    // --- LÓGICA MOCK ---
    await Future.delayed(const Duration(milliseconds: 600));

    if (slideId == "slide-1") {
      bool esCorrecto = answerIndex.contains(0);
      return {
        "attemptId": attemptId,
        "wasCorrect": esCorrecto,
        "pointsEarned": esCorrecto ? 1000 : 0,
        "updatedScore": esCorrecto ? 1000 : 0,
        "feedbackMessage": esCorrecto
            ? "¡Muy bien! Dart es potente."
            : "Nop, era Dart.",
        "attemptState": "IN_PROGRESS",
        "nextSlide": {
          "id": "slide-2",
          "questionType": "true_false",
          "questionText": "Pregunta 2: ¿Flutter es un Framework?",
          "options": [
            {"index": 0, "text": "Verdadero"},
            {"index": 1, "text": "Falso"},
          ],
        },
        "currentQuestionNumber": 2,
        "totalQuestions": 2,
      };
    } else {
      bool esCorrecto = answerIndex.contains(0);
      return {
        "attemptId": attemptId,
        "wasCorrect": esCorrecto,
        "pointsEarned": esCorrecto ? 1000 : 0,
        "updatedScore": esCorrecto ? 2000 : 1000,
        "feedbackMessage": "¡Juego terminado!",
        "attemptState": "COMPLETED",
        "nextSlide": null,
      };
    }

    /*
    // --- FUNCIÓN ORIGINAL API ---
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
    */
  }

  @override
  Future<GameSummary> getSummary(String attemptId) async {
    // --- LÓGICA MOCK ---
    await Future.delayed(const Duration(milliseconds: 500));
    return GameSummary.fromJson({
      "playerName": "Tester Pro",
      "totalScore": 1000,
      "correctAnswers": 2,
      "totalQuestions": 2,
    });

    /*
    // --- FUNCIÓN ORIGINAL API ---
    final response = await dio.get('/attempts/$attemptId/summary');
    return GameSummary.fromJson(response.data);
    */
  }

  @override
  Future<Attempt> getAttemptStatus(String attemptId) async {
    // --- LÓGICA MOCK (Simulación de reanudación) ---
    throw UnimplementedError("Mock no implementado para reanudación");

    /*
    // --- FUNCIÓN ORIGINAL API ---
    final response = await dio.get('/attempts/$attemptId');
    return Attempt.fromJson(response.data);
    */
  }
}
