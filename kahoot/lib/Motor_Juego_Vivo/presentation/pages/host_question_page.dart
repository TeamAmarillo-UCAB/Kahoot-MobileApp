import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/timer_widget.dart';
// ⚠️ IMPORTACIÓN CORREGIDA: Accede a la clase KahootColorsAndIcons
import 'player_question_page.dart'; 


class HostQuestionPage extends StatelessWidget {
  const HostQuestionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkBackground = const Color(0xFF222222);
    final cardColor = Colors.grey.shade900;
    final kahootYellow = const Color(0xFFFFD54F);

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
          backgroundColor: darkBackground,
          title: const Text('Host - Pregunta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<GameBloc, GameUiState>(builder: (context, state) {
        final slide = state.gameState.currentSlide;
        if (slide == null) return const Center(child: Text('Sin pregunta', style: TextStyle(color: Colors.white70)));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!state.isQuestion) {
            if (state.isResults) Navigator.of(context).pushReplacementNamed('/host_results');
            if (state.isEnd) Navigator.of(context).pushReplacementNamed('/host_podium');
          }
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Pregunta #${state.gameState.questionIndex}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kahootYellow)),
            const SizedBox(height: 16),
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(slide.questionText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),

            // Timer for host
            TimerWidget(seconds: slide.timeLimitSeconds, onStart: () {}, onFinished: () {
              context.read<GameBloc>().add(GameEventHostNextPhase());
            }),

            const SizedBox(height: 24),

            // Opciones (solo texto/indicador para el Host)
            ...slide.options.asMap().entries.map((entry) {
                final index = entry.key;
                final opt = entry.value;
                // ✅ USO CORRECTO DE LA CLASE PÚBLICA:
                final color = KahootColorsAndIcons.colors[index % KahootColorsAndIcons.colors.length]; 
                return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text(opt.text ?? 'Opción ${index + 1}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                );
            }).toList(),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: state.isLoading ? null : () => context.read<GameBloc>().add(GameEventHostNextPhase()),
                child: state.isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Mostrar resultados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        );
      }),
    );
  }
}