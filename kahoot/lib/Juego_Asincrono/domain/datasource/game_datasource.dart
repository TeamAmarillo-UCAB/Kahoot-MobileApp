import '../entities/attempt.dart';
import '../entities/game_summary.dart';

abstract class GameDatasource {
  /// Inicia un nuevo intento para un Kahoot específico
  Future<Attempt> startAttempt(String kahootId);

  /// Obtiene el estado actual de un intento
  Future<Attempt> getAttemptStatus(String attemptId);

  /// Envía la respuesta del usuario y recibe el feedback + siguiente slide
  Future<Map<String, dynamic>> submitAnswer({
    required String attemptId,
    required String slideId,
    required List<int> answerIndex,
    required int timeElapsedSeconds,
    String? textAnswer, // Opcional para Short Answer
  });

  /// Obtiene el resumen final de la partida
  Future<GameSummary> getSummary(String attemptId);
}
