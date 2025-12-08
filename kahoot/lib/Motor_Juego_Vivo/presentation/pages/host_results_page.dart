import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/scoreboard_widget.dart';

class HostResultsPage extends StatelessWidget {
  const HostResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkBackground = const Color(0xFF222222);
    final cardColor = Colors.grey.shade900;
    final kahootYellow = const Color(0xFFFFD54F);

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
          backgroundColor: darkBackground,
          title: const Text('Host - Resultados', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<GameBloc, GameUiState>(builder: (context, state) {
        final state = context.select((GameBloc bloc) => bloc.state);

        // 🚀 CORRECCIÓN DEL CRASH: Aplazamos la navegación.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!state.isResults) {
            // ✅ CORRECCIÓN DE RUTA: Eliminar rootNavigator: true.
            if (state.isQuestion) Navigator.of(context).pushReplacementNamed('/host_question');
            // ✅ CORRECCIÓN DE RUTA: Eliminar rootNavigator: true.
            if (state.isEnd) Navigator.of(context).pushReplacementNamed('/host_podium');
          }
        });

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (state.gameState.correctAnswerId != null)
                Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Card(
                      color: cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Respuesta Correcta: ${state.gameState.correctAnswerId}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kahootYellow)),
                      ),
                    ),
                ),
              Expanded(child: ScoreboardWidget(entries: state.gameState.scoreboard)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: state.isLoading ? null : () => context.read<GameBloc>().add(GameEventHostNextPhase()),
                  child: state.isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Siguiente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}