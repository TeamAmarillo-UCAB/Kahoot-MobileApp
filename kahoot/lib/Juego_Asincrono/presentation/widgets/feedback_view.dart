
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
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _controller.forward();

    // Pasar a siguiente pregunta tras 3 seg
    Timer(const Duration(seconds: 3), () {
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
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Texto Grande
            Text(
              widget.wasCorrect ? "CORRECTO" : "INCORRECTO",
              style: GameTextStyles.montserrat.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [const Shadow(color: Colors.black45, offset: Offset(2,2), blurRadius: 4)]
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Icono Animado (SOLO EL ASSET, SIN CONTENEDOR DE FONDO)
            ScaleTransition(
              scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
              // Eliminamos el Container con decoración y dejamos directo la imagen
              child: Image.asset(
                 widget.wasCorrect ? GameAssets.iconCorrect : GameAssets.iconWrong,
                 width: 120, // Aumenté un poco el tamaño para compensar la falta de fondo
                 height: 120,
                 fit: BoxFit.contain,
                 errorBuilder: (context, error, stackTrace) {
                   // Si falla el asset, mostramos un icono coloreado
                   return Icon(
                     widget.wasCorrect ? Icons.check_circle : Icons.cancel, 
                     size: 100, 
                     // Coloreamos el icono ya que no hay fondo
                     color: widget.wasCorrect ? GameColors.correctGreen : GameColors.wrongRed,
                     shadows: [const Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0,5))],
                   );
                 },
              ),
            ),

            const SizedBox(height: 30),

            // Puntos ganados (Solo si es correcto)
            if (widget.wasCorrect)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Text(
                  "+ ${widget.attempt.lastPointsEarned}",
                  style: GameTextStyles.montserrat.copyWith(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              
            const SizedBox(height: 10),
            
            // Mensaje motivacional
            Text(
               widget.wasCorrect ? "¡Sigue así!" : "¡A la próxima!",
               style: const TextStyle(color: Colors.white70, fontSize: 18, fontStyle: FontStyle.italic),
            )
          ],
        ),
      ),
    );
  }
}