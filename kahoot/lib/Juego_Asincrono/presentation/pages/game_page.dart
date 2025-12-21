import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          return KahootSlideTransition(
            child: _buildState(context, state),
          );
        },
      ),
    );
  }

  Widget _buildState(BuildContext context, GameState state) {
    if (state is GameLoading) {
      return const Center(child: CircularProgressIndicator());
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
    return const SizedBox();
  }
}
