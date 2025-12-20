import '../../domain/repositories/game_repository.dart';
import '../../core/result.dart';

class SubmitAnswer {
  final GameRepository repository;

  SubmitAnswer(this.repository);

  /// Envía la respuesta del usuario.
  /// [answerIndex] se usa para Quiz y True/False.
  /// [textAnswer] se usa para Short Answer.
  Future<Result<Map<String, dynamic>>> call({
    required String attemptId,
    required String slideId,
    required List<int> answerIndex,
    required int timeElapsed,
    String? textAnswer,
  }) async {
    return await repository.submitAnswer(
      attemptId: attemptId,
      slideId: slideId,
      answerIndex: answerIndex,
      timeElapsed: timeElapsed,
      textAnswer: textAnswer,
    );
  }
}
