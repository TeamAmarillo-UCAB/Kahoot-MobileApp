import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../application/usecases/start_attempt.dart';
import '../../application/usecases/submit_answer.dart';
import '../../application/usecases/get_summary.dart';
import '../../application/usecases/get_attempt_status.dart';
import '../../core/result.dart';
import 'game_event.dart';
import 'game_state.dart';
import '../../domain/entities/attempt.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final StartAttempt startAttempt;
  final SubmitAnswer submitAnswer;
  final GetSummary getGameSummary;
  final GetAttemptStatus getAttemptStatus;

  Attempt? _currentAttempt;
  String? _currentKahootId;
  int _counter = 1;

  GameBloc({
    required this.startAttempt,
    required this.submitAnswer,
    required this.getGameSummary,
    required this.getAttemptStatus,
  }) : super(GameInitial()) {
    on<OnStartGame>((event, emit) async {
      emit(GameLoading());
      _currentKahootId = event.kahootId;

      final prefs = await SharedPreferences.getInstance();

      final String? savedAttemptId = prefs.getString(
        'last_attempt_$_currentKahootId',
      );
      final int? savedCounter = prefs.getInt('last_counter_$_currentKahootId');

      Result<Attempt> result;

      if (savedAttemptId != null && savedAttemptId.isNotEmpty) {
        result = await getAttemptStatus(savedAttemptId);

        if (!result.isSuccessful() || result.getValue().isFinished) {
          result = await startAttempt(_currentKahootId!);
          _counter = 1;
        } else {
          _counter = savedCounter ?? 1;
        }
      } else {
        result = await startAttempt(_currentKahootId!);
        _counter = 1;
      }

      if (result.isSuccessful()) {
        _currentAttempt = result.getValue();

        await prefs.setString(
          'last_attempt_$_currentKahootId',
          _currentAttempt!.id,
        );
        await prefs.setInt('last_counter_$_currentKahootId', _counter);

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

      if (currentAttemptId == null || currentSlideId == null) return;

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
          lastPointsEarned: nextAttemptState.lastPointsEarned,
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
        emit(
          QuizState(
            attempt: _currentAttempt!,
            currentNumber: _counter,
            totalQuestions: 0,
          ),
        );
      }
    });

    on<OnNextQuestion>((event, emit) async {
      if (_currentAttempt == null || _currentKahootId == null) return;

      final prefs = await SharedPreferences.getInstance();

      if (_currentAttempt!.isFinished) {
        emit(GameLoading());

        await prefs.remove('last_attempt_$_currentKahootId');
        await prefs.remove('last_counter_$_currentKahootId');

        final result = await getGameSummary(_currentAttempt!.id);
        if (result.isSuccessful()) {
          emit(GameSummaryState(result.getValue()));
        } else {
          emit(GameError("Error al obtener el resumen"));
        }
      } else {
        _counter++;
        await prefs.setInt('last_counter_$_currentKahootId', _counter);

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
