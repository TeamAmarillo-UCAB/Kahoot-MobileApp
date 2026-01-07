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
        return Column(
          children: [
            LinearProgressIndicator(
              value: _controller.value,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _controller.value > 0.3 ? Colors.deepPurple : Colors.red,
              ),
              minHeight: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, size: 20),
                  const SizedBox(width: 5),
                  Text(
                    '${(widget.timeLimitSeconds * _controller.value).ceil()}s',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
