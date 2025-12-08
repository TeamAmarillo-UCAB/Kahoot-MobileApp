import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final int seconds;
  final VoidCallback? onStart;
  final VoidCallback? onFinished;

  const TimerWidget({Key? key, required this.seconds, this.onStart, this.onFinished}) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStart?.call();
      _start();
    });
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 0) {
        t.cancel();
        widget.onFinished?.call();
      } else {
        setState(() => _remaining -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.seconds == 0 ? 0.0 : _remaining / widget.seconds;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    // El color del indicador cambia a rojo al final para dar urgencia
    final indicatorColor = Color.lerp(Colors.red.shade700, primaryColor, pct); 
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Indicador de progreso más grueso y redondeado
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: pct, 
            minHeight: 15, // Aumentamos la altura
            backgroundColor: Colors.grey.shade800, // Fondo más oscuro para el tema
            color: indicatorColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tiempo restante', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white70)),
            // Mostramos el tiempo restante de forma destacada
            Text('${_remaining}s', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
          ],
        ),
      ],
    );
  }
}