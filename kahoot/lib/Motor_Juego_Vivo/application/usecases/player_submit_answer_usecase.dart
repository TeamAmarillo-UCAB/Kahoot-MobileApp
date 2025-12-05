// lib/Motor_Juego_Vivo/application/usecases/player_submit_answer_usecase.dart

import '../../domain/repositories/game_repository.dart';

class SubmitAnswerParams {
  final String questionId;
  final int answerId;
  final int timeElapsedMs;

  SubmitAnswerParams({
    required this.questionId,
    required this.answerId,
    required this.timeElapsedMs,
  });
}

class PlayerSubmitAnswerUsecase {
  final GameRepository repository;

  PlayerSubmitAnswerUsecase(this.repository);

  Future<void> call(SubmitAnswerParams params) {
    return repository.submitAnswer(
      questionId: params.questionId,
      answerId: params.answerId,
      timeElapsedMs: params.timeElapsedMs,
    );
  }
}
