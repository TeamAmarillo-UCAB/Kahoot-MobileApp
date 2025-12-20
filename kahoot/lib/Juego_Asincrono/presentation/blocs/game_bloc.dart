import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/start_attempt.dart';
import '../../application/usecases/submit_answer.dart';
import '../../application/usecases/get_summary.dart'; // Asegúrate de tener este caso de uso
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final StartAttempt startAttempt;
  final SubmitAnswer submitAnswer;
  final GetSummary getSummary;

  late dynamic _lastAttempt;

  GameBloc({
    required this.startAttempt,
    required this.submitAnswer,
    required this.getSummary,
  }) : super(GameInitial()) {
    on<OnStartGame>((event, emit) async {
      emit(GameLoading());
      final res = await startAttempt(event.kahootId);
      if (res.isSuccessful()) {
        _lastAttempt = res.getValue();
        emit(ShowingQuestion(attempt: _lastAttempt));
      }
    });

    on<OnSubmitAnswer>((event, emit) async {
      final res = await submitAnswer(
        attemptId: _lastAttempt.attemptId,
        slideId: _lastAttempt.nextSlide!.slideId,
        answerIndex: event.answerIndexes,
        timeElapsed: event.timeSeconds,
        textAnswer: event.textAnswer,
      );

      if (res.isSuccessful()) {
        _lastAttempt = res.getValue();
        emit(ShowingFeedback(attempt: _lastAttempt));
      }
    });

    on<OnNextQuestion>((event, emit) async {
      if (_lastAttempt.state == 'COMPLETED') {
        final res = await getSummary(_lastAttempt.attemptId);
        if (res.isSuccessful()) {
          emit(GameFinished(summary: res.getValue()));
        }
      } else {
        emit(ShowingQuestion(attempt: _lastAttempt));
      }
    });
  }
}
