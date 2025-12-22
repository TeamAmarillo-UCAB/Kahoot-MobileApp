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

      // Llamada al caso de uso StartAttempt (POST /attempts)
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
      if (_currentAttempt == null || _currentAttempt!.nextSlide == null) return;

      // Llamada al caso de uso SubmitAnswer (POST /attempts/{id}/answer)
      final result = await submitAnswer(
        attemptId: _currentAttempt!.id,
        slideId: _currentAttempt!.nextSlide!.slideId,
        answerIndex:
            event.answerIndexes, // Sincronizado con el nombre en el UseCase
        timeElapsed: event.timeSeconds,
      );

      if (result.isSuccessful()) {
        _currentAttempt = result.getValue();

        // El datasource mapea 'wasCorrect' y lo pone en la entidad Attempt
        emit(
          ShowingFeedback(
            attempt: _currentAttempt!,
            wasCorrect: _currentAttempt!.lastWasCorrect ?? false,
          ),
        );
      } else {
        emit(GameError("Error al procesar la respuesta"));
      }
    });

    on<OnNextQuestion>((event, emit) async {
      if (_currentAttempt == null) return;

      // Verificamos si el estado de la entidad es 'COMPLETED'
      if (_currentAttempt!.isFinished) {
        emit(GameLoading());

        // Llamada al caso de uso GetSummary (GET /attempts/{id}/summary)
        final result = await getGameSummary(_currentAttempt!.id);

        if (result.isSuccessful()) {
          emit(GameSummaryState(result.getValue()));
        } else {
          emit(GameError("Error al obtener el resumen final"));
        }
      } else {
        // Si no ha terminado, incrementamos contador y mostramos siguiente slide
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
