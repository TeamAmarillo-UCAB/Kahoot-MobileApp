import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kahoot/Juego_Asincrono/presentation/blocs/game_event.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_state.dart';
import '../widgets/quiz_view.dart';
import '../widgets/feedback_view.dart';
import '../widgets/slide_trasition.dart';
import 'game_summary_page.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return KahootSlideTransition(child: _buildState(context, state));
        },
      ),
    );
  }

  Widget _buildState(BuildContext context, GameState state) {
    if (state is GameInitial || state is GameLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      );
    }

    if (state is ShowingQuestion) {
      return QuizView(attempt: state.attempt);
    }

    if (state is ShowingFeedback) {
      return FeedbackView(attempt: state.attempt);
    }

    if (state is GameFinished) {
      return GameSummaryPage(summary: state.summary);
    }

    // --- NUEVO: Manejo de errores visual ---
    if (state is GameError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(color: Colors.black, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<GameBloc>().add(
                OnStartGame("3469833d-a967-4866-9654-d51929afafcc"),
              ),
              child: const Text("Reintentar"),
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Text(
        "Estado no reconocido",
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
