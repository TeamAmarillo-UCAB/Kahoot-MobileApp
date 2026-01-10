import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

// --- Infraestructura y Dominio ---
import '../../infrastructure/datasource/game_datasource_impl.dart';
import '../../infrastructure/repositories/game_repository_impl.dart';
import '../../application/usecases/start_attempt.dart';
import '../../application/usecases/submit_answer.dart';
import '../../application/usecases/get_summary.dart';
import '../../application/usecases/get_attempt_status.dart';

// --- Componentes del BLoC ---
import '../blocs/game_bloc.dart';
import '../blocs/game_state.dart';
import '../blocs/game_event.dart';

// --- Widgets y Utils ---
import '../widgets/quiz_view.dart';
import '../widgets/feedback_view.dart';
import 'game_summary_page.dart';
import '../utils/game_constants.dart';

class GamePage extends StatefulWidget {
  final String kahootId;
  const GamePage({super.key, required this.kahootId});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late final GameBloc _bloc;
  late String _currentBackground;

  @override
  void initState() {
    super.initState();

    // 1. Configuración de Infraestructura (Igual que en Home anteriormente)
    final dio = Dio(
      BaseOptions(baseUrl: 'https://quizzy-backend-0wh2.onrender.com/api'),
    );
    final datasource = GameDatasourceImpl(dio: dio);
    final repository = GameRepositoryImpl(datasource: datasource);

    // 2. Inicialización del BLoC con sus Casos de Uso
    _bloc = GameBloc(
      startAttempt: StartAttempt(repository),
      submitAnswer: SubmitAnswer(repository),
      getGameSummary: GetSummary(repository),
      getAttemptStatus: GetAttemptStatus(repository),
    )..add(OnStartGame(widget.kahootId)); // Disparamos el inicio del juego

    // 3. Fondo aleatorio
    final bgs = [
      GameAssets.bgBlue,
      GameAssets.bgPink,
      GameAssets.bgGreen,
      GameAssets.bgFall,
    ];
    _currentBackground = bgs[Random().nextInt(bgs.length)];
  }

  @override
  void dispose() {
    _bloc.close(); // Muy importante cerrar el bloc al salir
    super.dispose();
  }

  void _showExitMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.exit_to_app,
                color: GameColors.wrongRed,
              ),
              title: const Text(
                "Salir del juego",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: GameColors.wrongRed,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text("Cancelar"),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Proveemos el bloc a todo el árbol de la página
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8),
              decoration: const BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.white),
                onPressed: () => _showExitMenu(context),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                _currentBackground,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: GameColors.mainPurple),
              ),
            ),
            SafeArea(
              child: BlocBuilder<GameBloc, GameState>(
                builder: (context, state) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _buildStateWrapper(context, state),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateWrapper(BuildContext context, GameState state) {
    if (state is GameLoading) {
      return const Center(
        key: ValueKey('loading'),
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
        key: const ValueKey('feedback'),
        attempt: state.attempt,
        wasCorrect: state.wasCorrect,
      );
    }

    if (state is GameSummaryState) {
      return GameSummaryPage(
        key: const ValueKey('summary'),
        summary: state.summary,
      );
    }

    if (state is GameError) {
      return Center(
        key: const ValueKey('error'),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 80),
              const SizedBox(height: 16),
              Text(
                state.message,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: GameColors.mainPurple,
                ),
                onPressed: () => _bloc.add(OnStartGame(widget.kahootId)),
                child: const Text("Reintentar"),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Salir",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
