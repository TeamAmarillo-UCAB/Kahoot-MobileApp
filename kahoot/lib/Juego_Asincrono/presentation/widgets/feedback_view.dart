import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/attempt.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../utils/game_constants.dart';

class FeedbackView extends StatefulWidget {
  final Attempt attempt;
  final bool wasCorrect;

  const FeedbackView({
    super.key,
    required this.attempt,
    required this.wasCorrect,
  });

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animación de "Pop" del texto
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();

    // Pasar a la siguiente pregunta tras 3 segundos
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        context.read<GameBloc>().add(OnNextQuestion());
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definir mensajes aleatorios o fijos
    final randomMsg = widget.wasCorrect 
        ? ["¡Genial!", "¡En racha!", "¡Así se hace!"] 
        : ["¡Ups!", "La próxima sale", "No te rindas"];
    final msg = randomMsg[DateTime.now().millisecond % randomMsg.length];

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: widget.wasCorrect ? GameColors.correctGreen : GameColors.wrongRed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Text(
              widget.wasCorrect ? "CORRECTO" : "INCORRECTO",
              style: const TextStyle(
                fontSize: 45, 
                fontWeight: FontWeight.w900, 
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Icono
          Image.asset(
             widget.wasCorrect ? GameAssets.iconCorrect : GameAssets.iconWrong,
             height: 120,
             errorBuilder: (_,__,___) => Icon(
               widget.wasCorrect ? Icons.check : Icons.close, 
               size: 100, color: Colors.white
             ),
          ),

          const SizedBox(height: 30),
          
          // Mensaje gracioso
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: Colors.black12,
            child: Text(
              msg,
              style: const TextStyle(fontSize: 20, color: Colors.white, fontStyle: FontStyle.italic),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Puntos ganados
          Text(
            "+ ${widget.attempt.lastPointsEarned}",
            style: const TextStyle(
               fontSize: 30, 
               fontWeight: FontWeight.bold, 
               color: Colors.white,
               backgroundColor: Colors.black26
            ),
          ),
          const SizedBox(height: 10),
           Text(
            "Total: ${widget.attempt.currentScore}",
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
