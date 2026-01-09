import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/attempt.dart';
import '../../domain/entities/slide.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import '../utils/game_constants.dart';
import 'animated_timer_bar.dart';
import 'option_title.dart';
import 'question_header.dart';

enum QuizPhase { intro, content }

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
  QuizPhase _phase = QuizPhase.intro;
  bool _hasAnswered = false;

  Timer? _questionTimer;
  double _timerProgress = 1.0;
  List<int> _selectedIndices = [];
  late int _timeLimitSeconds;

  late AnimationController _optionsController;
  late Animation<Offset> _optionsSlideAnimation;

  @override
  void initState() {
    super.initState();
    _optionsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _optionsSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _optionsController, curve: Curves.elasticOut),
        );

    _startSequence();
  }

  void _startSequence() {
    setState(() => _phase = QuizPhase.intro);

    Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() {
        _phase = QuizPhase.content;
      });
      _startTimer();
      _optionsController.forward();
    });
  }

  void _startTimer() {
    final slide = widget.attempt.nextSlide!;
    _timeLimitSeconds = slide.timeLimit > 0 ? slide.timeLimit : 20;
    int remaining = _timeLimitSeconds * 100;
    int total = remaining;

    _questionTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!mounted) return;
      setState(() {
        remaining--;
        _timerProgress = remaining / total;
      });

      if (remaining <= 0) {
        timer.cancel();
        _submitAnswer(timeOut: true);
      }
    });
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _optionsController.dispose();
    super.dispose();
  }

  void _onOptionSelected(int index, String type) {
    if (_hasAnswered) return;

    setState(() {
      if (type == 'MULTIPLE') {
        if (_selectedIndices.contains(index)) {
          _selectedIndices.remove(index);
        } else {
          _selectedIndices.add(index);
        }
      } else {
        _selectedIndices = [index];
        _submitAnswer();
      }
    });
  }

  void _submitAnswer({bool timeOut = false}) {
    _questionTimer?.cancel();
    setState(() => _hasAnswered = true);

    final timeElapsed = ((1.0 - _timerProgress) * _timeLimitSeconds).toInt();

    context.read<GameBloc>().add(
      OnSubmitAnswer(answerIndexes: _selectedIndices, timeSeconds: timeElapsed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.attempt.nextSlide!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: _phase == QuizPhase.intro
          ? _buildIntroView(slide)
          : _buildGameView(slide),
    );
  }

  Widget _buildIntroView(Slide slide) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      key: const ValueKey('intro'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Pregunta ${widget.currentNumber}",
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 24,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Image.asset(
                _getIconForType(slide.type),
                width: 60,
                height: 60,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.quiz,
                  size: 60,
                  color: GameColors.amberTheme,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              decoration: BoxDecoration(
                color: GameColors.amberTheme,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                slide.type.replaceAll('_', ' '),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameView(Slide slide) {
    return Scaffold(
      key: const ValueKey('game'),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            QuestionHeader(currentNumber: widget.currentNumber, slide: slide),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 100),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          slide.question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 3. Imagen (Modificada para usar la URL directa de Cloudinary)
                    if (slide.mediaId != null && slide.mediaId!.isNotEmpty)
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black12,
                            image: DecorationImage(
                              image: NetworkImage(slide.mediaId!),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      )
                    else
                      const Spacer(),

                    const SizedBox(height: 10),

                    SlideTransition(
                      position: _optionsSlideAnimation,
                      child: _buildOptionsArea(slide),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            AnimatedTimerBar(progress: _timerProgress),

            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsArea(Slide slide) {
    int crossAxisCount = 2;
    double aspectRatio = 1.3;

    final bool showSubmitButton =
        slide.type == 'MULTIPLE' || slide.type == 'SHORT_ANSWER';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: slide.options.length,
          itemBuilder: (context, index) {
            final option = slide.options[index];
            final isSelected = _selectedIndices.contains(option.index);

            return OptionTitle(
              option: option,
              index: index,
              isSelected: isSelected,
              onTap: () => _onOptionSelected(option.index, slide.type),
            );
          },
        ),

        if (showSubmitButton) ...[
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedIndices.isNotEmpty
                    ? GameColors.amberTheme
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _selectedIndices.isNotEmpty
                  ? () => _submitAnswer()
                  : null,
              child: const Text(
                "Enviar Respuesta",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Colors.black26,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "JovaniVazques",
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${widget.attempt.currentScore}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getIconForType(String type) {
    switch (type) {
      case 'TRUE_FALSE':
        return GameAssets.iconTrueFalse;
      case 'SHORT_ANSWER':
        return GameAssets.iconShortAnswer;
      case 'SLIDE':
        return GameAssets.iconSlide;
      default:
        return GameAssets.iconQuiz;
    }
  }
}
