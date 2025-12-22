import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/start_attempt.dart';
import '../../application/usecases/submit_answer.dart';
import '../../application/usecases/get_summary.dart';
import '../../application/usecases/get_attempt_status.dart';
import 'game_event.dart';
import 'game_state.dart';
import '../../domain/entities/attempt.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final StartAttempt startAttempt;
  final SubmitAnswer submitAnswer;
  final GetSummary getGameSummary;
  final GetAttemptStatus getAttemptStatus;

  Attempt? _currentAttempt;
  int _counter = 1;

  GameBloc({
    required this.startAttempt,
    required this.submitAnswer,
    required this.getGameSummary,
    required this.getAttemptStatus,
  }) : super(GameInitial()) {
    on<OnStartGame>((event, emit) async {
      emit(GameLoading());
      final result = await startAttempt(event.kahootId);

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
        emit(GameError("Error al iniciar la partida"));
      }
    });

    on<OnSubmitAnswer>((event, emit) async {
      // CAPTURA DE SEGURIDAD: Guardamos las referencias antes de llamar a la API
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

        // MANTENIMIENTO DE ESTADO:
        // Si el servidor no devuelve el attemptId en la respuesta del POST,
        // nos aseguramos de no perder el que ya teníamos.
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
        // Si hay error lógico del servidor, lo mostramos sin resetear el contador
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
