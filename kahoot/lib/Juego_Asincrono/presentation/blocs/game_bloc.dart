import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/start_attempt.dart';
import '../../application/usecases/submit_answer.dart';
import '../../application/usecases/get_summary.dart';
import '../../application/usecases/get_attempt_status.dart'; // <--- IMPORTAR
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final StartAttempt startAttempt;
  final GetAttemptStatus getAttemptStatus; // <--- NUEVA DEPENDENCIA
  final SubmitAnswer submitAnswer;
  final GetSummary getSummary;

  late dynamic _lastAttempt; // Te sugiero tipar esto como 'Attempt?' en el futuro

  GameBloc({
    required this.startAttempt,
    required this.getAttemptStatus, // <--- RECIBIR EN CONSTRUCTOR
    required this.submitAnswer,
    required this.getSummary,
  }) : super(GameInitial()) {

    // Lógica existente de Iniciar Juego
    on<OnStartGame>((event, emit) async {
      emit(GameLoading());
      final res = await startAttempt(event.kahootId);
      if (res.isSuccessful()) {
        _lastAttempt = res.getValue();
        emit(ShowingQuestion(attempt: _lastAttempt));
      } else {
        // Manejo básico de error
        emit(GameError("No se pudo iniciar el juego")); 
      }
    });

    // --- NUEVA LÓGICA: REANUDAR JUEGO ---
    on<OnResumeGame>((event, emit) async {
      emit(GameLoading());
      // 1. Llamamos al caso de uso para obtener el estado actual
      final res = await getAttemptStatus(event.attemptId);
      
      if (res.isSuccessful()) {
        _lastAttempt = res.getValue();

        // 2. Verificamos el estado en el que vino la partida
        if (_lastAttempt.state == 'COMPLETED') {
          // Si ya estaba completado, disparamos la lógica de resumen
          // Podemos reutilizar la lógica llamando al evento OnNextQuestion 
          // o llamando a getSummary directamente.
          add(OnNextQuestion()); 
        } else {
          // Si está IN_PROGRESS, mostramos la slide que toque (nextSlide)
          // Nota: El endpoint getAttemptStatus devuelve 'nextSlide' según la doc.
          emit(ShowingQuestion(attempt: _lastAttempt));
        }
      } else {
        emit(GameError("No se pudo recuperar la partida"));
      }
    });
    // -------------------------------------

    on<OnSubmitAnswer>((event, emit) async {
      // (Tu código existente sin cambios)
      // Solo asegúrate de manejar errores si res no es exitoso
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
       // (Tu código existente sin cambios)
      if (_lastAttempt.state == 'COMPLETED') {
        emit(GameLoading());
        final summaryRes = await getSummary(_lastAttempt.attemptId);
        if (summaryRes.isSuccessful()) {
          emit(GameFinished(summary: summaryRes.getValue()));
        }
      } else {
        emit(ShowingQuestion(attempt: _lastAttempt));
      }
    });
  }
}