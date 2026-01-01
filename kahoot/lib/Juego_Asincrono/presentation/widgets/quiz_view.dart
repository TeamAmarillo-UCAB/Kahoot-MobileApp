import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/attempt.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../utils/game_constants.dart';
import 'animated_timer_bar.dart';
import 'option_title.dart';

class QuizView extends StatefulWidget {
  final Attempt attempt;
  final int currentNumber;
  final int totalQuestions;

  const QuizView({
    super.key,
    required this.attempt,
    required this.currentNumber,
    required this.totalQuestions,
  });

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> with TickerProviderStateMixin {
  // Estados internos de la vista
  bool _showingTransition = true; // Empieza mostrando la transición (ej: "Quiz")
  bool _hasAnswered = false;
  
  // Lógica del Timer y Selección
  Timer? _questionTimer;
  double _timerProgress = 1.0;
  List<int> _selectedIndices = [];
  late final int _timeLimitSeconds;
  DateTime? _startQuestionTime; // Momento exacto en que se muestra la pregunta

  // Animaciones
  late AnimationController _transitionController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _timeLimitSeconds = widget.attempt.nextSlide?.timeLimit ?? 30;

    // Configurar animación de entrada de la pregunta
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // Viene un poco de abajo
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _transitionController, curve: Curves.easeOut));

    // INICIAR SECUENCIA:
    // 1. Mostrar pantalla de transición por 2.5 segundos
    // 2. Ocultar transición, mostrar pregunta y arrancar timer
    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    setState(() {
      _showingTransition = false;
    });
    
    _transitionController.forward(); // Animar entrada de elementos
    _startTimer(); // Arrancar el reloj
  }

  void _startTimer() {
    _startQuestionTime = DateTime.now();
    
    _questionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final elapsedMs = now.difference(_startQuestionTime!).inMilliseconds;
      final totalMs = _timeLimitSeconds * 1000;
      
      final newProgress = 1 - (elapsedMs / totalMs);

      if (newProgress <= 0) {
        timer.cancel();
        setState(() => _timerProgress = 0);
        if (!_hasAnswered) _submit(); // Timeout
      } else {
        setState(() => _timerProgress = newProgress);
      }
    });
  }

  void _onOptionTap(int index, String type) {
    if (_hasAnswered) return;

    setState(() {
      if (type == "MULTIPLE") {
        if (_selectedIndices.contains(index)) {
          _selectedIndices.remove(index);
        } else {
          _selectedIndices.add(index);
        }
      } else {
        // SINGLE o TRUE_FALSE
        _selectedIndices = [index];
        _submit(); // Auto-enviar
      }
    });
  }

  void _submit() {
    if (_hasAnswered) return;
    _hasAnswered = true;
    _questionTimer?.cancel();

    final now = DateTime.now();
    // Calcular tiempo real tomado desde que se mostró la pregunta
    final secondsTaken = _startQuestionTime != null 
        ? now.difference(_startQuestionTime!).inSeconds 
        : _timeLimitSeconds;

    context.read<GameBloc>().add(
      OnSubmitAnswer(
        answerIndexes: _selectedIndices,
        timeSeconds: secondsTaken.clamp(1, _timeLimitSeconds),
      ),
    );
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.attempt.nextSlide;
    if (slide == null) return const SizedBox.shrink();

    // -- FASE 1: TRANSICIÓN --
    if (_showingTransition) {
      return _buildTransitionScreen(slide.type);
    }

    // -- FASE 2: PREGUNTA --
    return FadeTransition(
      opacity: _transitionController,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Cabecera (Pregunta)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))]
              ),
              child: Text(
                slide.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 10),

            // Imagen (Si existe)
            if (slide.mediaId != null)
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage('https://quizzy-backend-0wh2.onrender.com/api/media/${slide.mediaId}'),
                      fit: BoxFit.contain, // Para que se vea toda la imagen
                    ),
                  ),
                ),
              )
            else 
              const Spacer(flex: 1),

            // Timer Bar (Estilo Kahoot: barra morada que decrece)
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
               child: Row(
                 children: [
                   // Círculo con segundos restantes
                   Container(
                     width: 40, height: 40,
                     alignment: Alignment.center,
                     decoration: const BoxDecoration(color: GameColors.mainPurple, shape: BoxShape.circle),
                     child: Text(
                       "${(_timerProgress * _timeLimitSeconds).ceil()}", 
                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                     ),
                   ),
                   const SizedBox(width: 10),
                   Expanded(child: AnimatedTimerBar(progress: _timerProgress)),
                 ],
               ),
            ),

            // Opciones (Grid)
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildOptionsGrid(slide),
              ),
            ),
            
            // Botón enviar (Solo para MULTIPLE)
            if (slide.type == "MULTIPLE" && _selectedIndices.isNotEmpty && !_hasAnswered)
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GameColors.mainPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _submit,
                  child: const Text("ENVIAR", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              
            // Info usuario pie de pagina
             Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Puntos: ${widget.attempt.currentScore}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para la pantalla intermedia "Pregunta 1 - Quiz"
  Widget _buildTransitionScreen(String type) {
    String typeText = "Quiz";
    String iconPath = GameAssets.iconQuiz;

    if (type == "TRUE_FALSE") {
      typeText = "Verdadero o Falso";
      iconPath = GameAssets.iconTrueFalse;
    } else if (type == "MULTIPLE") {
      typeText = "Selección Múltiple";
      iconPath = GameAssets.iconQuiz; // O uno específico si tienes
    } else if (type == "SHORT_ANSWER") {
      typeText = "Respuesta Corta";
      iconPath = GameAssets.iconShortAnswer;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${widget.currentNumber}",
            style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            "Prepárate...",
            style: TextStyle(fontSize: 24, color: Colors.white70),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Image.asset(iconPath, width: 60, height: 60, errorBuilder: (_,__,___) => const Icon(Icons.help, size: 60)),
          ),
          const SizedBox(height: 20),
          Text(
            typeText,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(slide) {
    // Si es Verdadero/Falso, usamos layout específico o grid de 2
    // Aquí asumimos Grid para todo por simplicidad y consistencia visual
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.3, // Aspecto rectangular tipo botón
      ),
      itemCount: slide.options.length,
      itemBuilder: (context, index) {
        final option = slide.options[index];
        final isSelected = _selectedIndices.contains(option.index);
        
        return OptionTitle(
          option: option,
          index: index, // Pasamos índice para color
          isSelected: isSelected,
          onTap: () => _onOptionTap(option.index, slide.type),
        );
      },
    );
  }
}