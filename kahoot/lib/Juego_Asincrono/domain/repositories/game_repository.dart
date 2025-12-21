import '../../../common/core/result.dart';
import '../entities/attempt.dart';
import '../entities/game_summary.dart';

abstract class GameRepository {
  /// Inicia un nuevo intento de juego para un Kahoot específico
  Future<Result<Attempt>> startAttempt(String kahootId);

  /// Recupera el estado actual de un intento (útil para reconexión)
  Future<Result<Attempt>> getAttemptStatus(String attemptId);

  /// Envía la respuesta del usuario y devuelve el resultado actualizado
  /// (Incluye feedback, puntos y la siguiente pregunta)
  Future<Result<Attempt>> submitAnswer({
    required String attemptId,
    required String slideId,
    required List<int> answerIndex,
    required int timeElapsed,
    String? textAnswer,
  });

  /// Obtiene los resultados finales una vez el juego ha terminado
  Future<Result<GameSummary>> getSummary(String attemptId);
}
