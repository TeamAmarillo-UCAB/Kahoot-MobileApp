import '../../domain/repositories/game_repository.dart';
import '../../domain/datasource/game_datasource.dart';
import '../../domain/entities/attempt.dart';
import '../../domain/entities/game_summary.dart';
import '../../core/result.dart';

class GameRepositoryImpl implements GameRepository {
  final GameDatasource datasource;

  GameRepositoryImpl({required this.datasource});

  @override
  Future<Result<Attempt>> startAttempt(String kahootId) async {
    try {
      final attempt = await datasource.startAttempt(kahootId);
      return Result.success(attempt);
    } catch (e) {
      return Result.makeError(Exception('No se pudo iniciar el juego: $e'));
    }
  }

  @override
  Future<Result<Attempt>> getAttemptStatus(String attemptId) async {
    try {
      final attempt = await datasource.getAttemptStatus(attemptId);
      return Result.success(attempt);
    } catch (e) {
      return Result.makeError(Exception('Error al recuperar el estado: $e'));
    }
  }

  @override
  Future<Result<Attempt>> submitAnswer({
    required String attemptId,
    required String slideId,
    required List<int> answerIndex,
    required int timeElapsed,
    String? textAnswer,
  }) async {
    try {
      // Llamamos al datasource que nos devuelve el JSON (Map)
      final data = await datasource.submitAnswer(
        attemptId: attemptId,
        slideId: slideId,
        answerIndex: answerIndex,
        timeElapsedSeconds: timeElapsed,
        textAnswer: textAnswer,
      );

      // Convertimos ese JSON directamente en una entidad Attempt
      // que ya contiene el feedbackMessage y el nextSlide
      final updatedAttempt = Attempt.fromJson(data);

      return Result.success(updatedAttempt);
    } catch (e) {
      return Result.makeError(Exception('Error al enviar la respuesta: $e'));
    }
  }

  @override
  Future<Result<GameSummary>> getSummary(String attemptId) async {
    try {
      final summary = await datasource.getSummary(attemptId);
      return Result.success(summary);
    } catch (e) {
      return Result.makeError(Exception('Error al obtener el resumen: $e'));
    }
  }
}
