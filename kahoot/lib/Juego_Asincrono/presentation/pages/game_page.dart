import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_state.dart';
import '../blocs/game_event.dart';
import '../widgets/quiz_view.dart';
import '../widgets/feedback_view.dart';
import '../widgets/slide_trasition.dart';
import 'game_summary_page.dart';

class GamePage extends StatelessWidget {
  final String kahootId;
  const GamePage({super.key, required this.kahootId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF46178F),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return KahootSlideTransition(
            child: _buildStateWrapper(context, state),
          );
        },
      ),
    );
  }

  Widget _buildStateWrapper(BuildContext context, GameState state) {
    if (state is GameLoading) {
      return const Center(
        key: ValueKey('loading_state'),
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (state is QuizState) {
      return QuizView(
        key: ValueKey('quiz_${state.currentNumber}'),
        attempt: state.attempt,
        currentNumber: state.currentNumber,
        totalQuestions: state.totalQuestions,
      );
    }

    if (state is ShowingFeedback) {
      return FeedbackView(
        key: const ValueKey('feedback_state'),
        attempt: state.attempt,
        wasCorrect: state.wasCorrect,
      );
    }

    if (state is GameSummaryState) {
      return GameSummaryPage(
        key: const ValueKey('summary_state'),
        summary: state.summary,
      );
    }

    if (state is GameError) {
      return Center(
        key: const ValueKey('error_state'),
        child: _ErrorBody(message: state.message, kahootId: kahootId),
      );
    }

    return const SizedBox.shrink(key: ValueKey('empty_state'));
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final String kahootId;
  const _ErrorBody({required this.message, required this.kahootId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 80),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                context.read<GameBloc>().add(OnStartGame(kahootId)),
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }
}
