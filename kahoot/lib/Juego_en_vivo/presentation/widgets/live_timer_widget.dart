import 'package:flutter/material.dart';

class LiveTimerWidget extends StatefulWidget {
  final int timeLimitSeconds;
  final VoidCallback? onTimerFinished;

  const LiveTimerWidget({
    super.key,
    required this.timeLimitSeconds,
    this.onTimerFinished,
  });

  @override
  State<LiveTimerWidget> createState() => _LiveTimerWidgetState();
}

class _LiveTimerWidgetState extends State<LiveTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.timeLimitSeconds),
    );

    _controller.reverse(from: 1.0).then((_) {
      if (widget.onTimerFinished != null) widget.onTimerFinished!();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculamos la posición X basada en el porcentaje de la barra
            final double width = constraints.maxWidth;
            final double currentPosition = width * _controller.value;

            return Column(
              children: [
                Stack(
                  clipBehavior: Clip
                      .none, // Permite que el texto sobresalga si es necesario
                  children: [
                    // La barra de progreso
                    LinearProgressIndicator(
                      value: _controller.value,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _controller.value > 0.3
                            ? Colors.cyanAccent
                            : Colors.redAccent,
                      ),
                      minHeight: 12,
                    ),
                    // El número que "sigue" a la barra
                    Positioned(
                      left:
                          currentPosition -
                          20, // Ajuste para que el texto flote sobre el final
                      top: 15, // Lo posicionamos justo debajo de la barra
                      child: Text(
                        '${(widget.timeLimitSeconds * _controller.value).ceil()}s',
                        style: TextStyle(
                          color: _controller.value > 0.3
                              ? Colors.white
                              : Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ), // Espacio para que el número no choque con la pregunta
              ],
            );
          },
        );
      },
    );
  }
}
