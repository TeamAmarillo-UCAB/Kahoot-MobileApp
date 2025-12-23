import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kahoot/common/core/result.dart';
import '../../application/usecases/start_attempt.dart';
import '../../application/usecases/submit_answer.dart';
import '../../application/usecases/get_summary.dart';
import '../../application/usecases/get_attempt_status.dart';
import '../../application/usecases/check_active_attempt.dart';
import 'game_event.dart';
import 'game_state.dart';
import '../../domain/entities/attempt.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final StartAttempt startAttempt;
  final SubmitAnswer submitAnswer;
  final GetSummary getGameSummary;
  final GetAttemptStatus getAttemptStatus;
  final CheckActiveAttempt checkActiveAttempt;

  Attempt? _currentAttempt;
  int _counter = 1;

  GameBloc({
    required this.startAttempt,
    required this.submitAnswer,
    required this.getGameSummary,
    required this.getAttemptStatus,
    required this.checkActiveAttempt,
  }) : super(GameInitial()) {
    on<OnStartGame>((event, emit) async {
      emit(GameLoading());
      /* PARA CUANDO SE TENGA EL TOKEN Y SE PUEDA RESTAURAR EL PROGRESO
      final activeCheckResult = await checkActiveAttempt(event.kahootId);
      String? existingAttemptId;

      if (activeCheckResult.isSuccessful()) {
        existingAttemptId = activeCheckResult.getValue();
      }

      Result<Attempt> result;

      if (existingAttemptId != null && existingAttemptId.isNotEmpty) {
        result = await getAttemptStatus(existingAttemptId);
      } else {
        result = await startAttempt(event.kahootId);
      }
      */
      Result<Attempt> result;
      result = await startAttempt(event.kahootId);

      if (result.isSuccessful()) {
        _currentAttempt = result.getValue();

        _counter = 1;

        emit(
          QuizState(
            attempt: _currentAttempt!,
            currentNumber: _counter,
            totalQuestions: 0,
          ),
        );
      } else {
        emit(GameError("No se pudo iniciar o recuperar la partida"));
      }
    });

    on<OnSubmitAnswer>((event, emit) async {
      final String? currentAttemptId = _currentAttempt?.id;
      final String? currentSlideId = _currentAttempt?.nextSlide?.slideId;

      if (currentAttemptId == null || currentSlideId == null) {
        emit(GameError("Error de sincronización: No hay slide activo"));
        return;
      }

      final result = await submitAnswer(
        attemptId: currentAttemptId,
        slideId: currentSlideId,
        answerIndex: event.answerIndexes,
        timeElapsed: event.timeSeconds,
      );

      if (result.isSuccessful()) {
        final nextAttemptState = result.getValue();

        _currentAttempt = Attempt(
          id: nextAttemptState.id.isEmpty
              ? currentAttemptId
              : nextAttemptState.id,
          state: nextAttemptState.state,
          currentScore: nextAttemptState.currentScore,
          nextSlide: nextAttemptState.nextSlide,
          lastWasCorrect: nextAttemptState.lastWasCorrect,
        );

        emit(
          ShowingFeedback(
            attempt: _currentAttempt!,
            wasCorrect: _currentAttempt!.lastWasCorrect ?? false,
          ),
        );
      } else {
        emit(GameError("Error del servidor al procesar la respuesta"));
      }
    });

    on<OnNextQuestion>((event, emit) async {
      if (_currentAttempt == null) return;

      if (_currentAttempt!.isFinished) {
        emit(GameLoading());
        final result = await getGameSummary(_currentAttempt!.id);
        if (result.isSuccessful()) {
          emit(GameSummaryState(result.getValue()));
        } else {
          emit(GameError("Error al obtener el resumen"));
        }
      } else {
        _counter++;
        emit(
          QuizState(
            attempt: _currentAttempt!,
            currentNumber: _counter,
            totalQuestions: 0,
          ),
        );
      }
    });
  }
}
