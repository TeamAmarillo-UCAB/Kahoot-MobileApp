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
            final double width = constraints.maxWidth;
            final double currentPosition = width * _controller.value;

            return Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
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
                    Positioned(
                      left: currentPosition - 20,
                      top: 15,
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
                const SizedBox(height: 25),
              ],
            );
          },
        );
      },
    );
  }
}
