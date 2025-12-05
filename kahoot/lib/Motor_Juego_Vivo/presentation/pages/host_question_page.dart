import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/timer_widget.dart';

class HostQuestionPage extends StatelessWidget {
  const HostQuestionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host - Pregunta')),
      body: BlocBuilder<GameBloc, GameUiState>(builder: (context, state) {
        final slide = state.gameState.currentSlide;
        if (slide == null) return const Center(child: Text('Sin pregunta'));

        // React to unexpected phase changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!state.isQuestion) {
            if (state.isResults) Navigator.of(context).pushReplacementNamed('/host_results');
            if (state.isEnd) Navigator.of(context).pushReplacementNamed('/host_podium');
          }
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Pregunta #${state.gameState.questionIndex}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(slide.questionText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),

            // Timer for host - when finished we also advance to results
            TimerWidget(seconds: slide.timeLimitSeconds, onStart: () {}, onFinished: () {
              context.read<GameBloc>().add(GameEventHostNextPhase());
            }),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: state.isLoading ? null : () => context.read<GameBloc>().add(GameEventHostNextPhase()),
                child: state.isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Mostrar resultados'),
              ),
            ),
          ]),
        );
      }),
    );
  }
}
