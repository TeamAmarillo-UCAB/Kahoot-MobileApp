import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/attempt.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../widgets/animated_timer_bar.dart';
import '../widgets/question_header.dart';
import '../widgets/option_title.dart';

class QuizView extends StatefulWidget {
  final Attempt attempt;
  const QuizView({super.key, required this.attempt});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  Timer? _timer;
  double progress = 1.0;
  final int timeLimit = 30; // TODO: obtener timeLimitSeconds desde Slide
  late final DateTime startTime;
  bool answered = false;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      setState(() {
        progress = 1 - (elapsed / (timeLimit * 1000));
      });

      if (progress <= 0 && !answered) {
        answered = true;
        context.read<GameBloc>().add(
          OnSubmitAnswer(
            answerIndexes: [],
            timeSeconds: timeLimit,
          ),
        );
        timer.cancel();
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
    final slide = widget.attempt.nextSlide!;

    return Column(
      children: [
        QuestionHeader(slide: slide),
        AnimatedTimerBar(progress: progress),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            padding: const EdgeInsets.all(12),
            children: slide.options.map((o) {
              return OptionTile(
                option: o,
                onTap: () {
                  if (answered) return;
                  answered = true;

                  final seconds =
                      DateTime.now().difference(startTime).inSeconds;

                  context.read<GameBloc>().add(
                        OnSubmitAnswer(
                          answerIndexes: [int.parse(o.index)],
                          timeSeconds: seconds,
                        ),
                      );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
