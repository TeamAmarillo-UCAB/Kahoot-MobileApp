import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/attempt.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import 'animated_timer_bar.dart';
import 'option_title.dart';
import 'question_header.dart';

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

class _QuizViewState extends State<QuizView> {
  Timer? _timer;
  double progress = 1.0;
  bool _hasAnswered = false;
  List<int> selectedIndices = [];

  late final int timeLimit;
  late final DateTime startTime;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    timeLimit = widget.attempt.nextSlide?.timeLimit ?? 30;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final newProgress = 1 - (elapsed / (timeLimit * 1000));

      if (newProgress <= 0) {
        timer.cancel();
        if (!_hasAnswered) _submit();
      } else {
        setState(() => progress = newProgress);
      }
    });
  }

  void _onOptionTap(int index) {
    if (_hasAnswered) return;

    final slide = widget.attempt.nextSlide;
    if (slide == null) return;

    setState(() {
      if (slide.type == "MULTIPLE") {
        if (selectedIndices.contains(index)) {
          selectedIndices.remove(index);
        } else {
          selectedIndices.add(index);
        }
      } else {
        selectedIndices = [index];
        _submit();
      }
    });
  }

  void _submit() {
    if (_hasAnswered || !mounted) return;
    _hasAnswered = true;
    _timer?.cancel();

    final seconds = DateTime.now().difference(startTime).inSeconds;

    context.read<GameBloc>().add(
      OnSubmitAnswer(
        answerIndexes: selectedIndices,
        timeSeconds: seconds.clamp(1, timeLimit),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.attempt.nextSlide;
    if (slide == null) return const SizedBox.shrink();
    final remainingSeconds = (progress * timeLimit).ceil().clamp(0, timeLimit);

    return Column(
      children: [
        QuestionHeader(
          slide: slide,
          currentNumber: widget.currentNumber,
          totalQuestions: widget.totalQuestions,
        ),

        if (slide.mediaId != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                'https://quizzy-backend-0wh2.onrender.com/api/media/${slide.mediaId}',
                height: MediaQuery.of(context).size.height * 0.2,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  color: Colors.white24,
                  size: 50,
                ),
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF46178F),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$remainingSeconds",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: AnimatedTimerBar(progress: progress)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: slide.options.length,
            itemBuilder: (context, index) {
              final option = slide.options[index];
              final isSelected = selectedIndices.contains(option.index);
              return OptionTitle(
                option: option,
                isSelected: isSelected,
                onTap: () => _onOptionTap(option.index),
              );
            },
          ),
        ),
        if (slide.type == "MULTIPLE" &&
            selectedIndices.isNotEmpty &&
            !_hasAnswered)
          Padding(
            padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF46178F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                onPressed: _submit,
                child: const Text(
                  "ENVIAR RESPUESTA",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white30, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Juan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Puntos: ${widget.attempt.currentScore}",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
