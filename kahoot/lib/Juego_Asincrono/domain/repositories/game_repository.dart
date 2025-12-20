import '../../core/result.dart';
import '../entities/attempt.dart';
import '../entities/game_summary.dart';

abstract class GameRepository {
  /// Inicia el juego y devuelve el objeto Attempt con la primera pregunta
  Future<Result<Attempt>> startAttempt(String kahootId);

  /// Recupera el estado de un juego en curso
  Future<Result<Attempt>> getAttemptStatus(String attemptId);

  /// Envía la respuesta y devuelve un Mapa con:
  /// 'wasCorrect', 'pointsEarned', 'updatedScore', 'attemptState' y 'nextSlide'
  Future<Result<Map<String, dynamic>>> submitAnswer({
    required String attemptId,
    required String slideId,
    required List<int> answerIndex,
    required int timeElapsed,
    String? textAnswer,
  });

  /// Devuelve los datos finales del juego
  Future<Result<GameSummary>> getSummary(String attemptId);
}
