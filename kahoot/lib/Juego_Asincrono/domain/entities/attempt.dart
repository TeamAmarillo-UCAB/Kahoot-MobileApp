import 'slide.dart';

class Attempt {
  final String attemptId;
  final String playerName;
  final int currentScore;
  final String state; // 'IN_PROGRESS', 'COMPLETED'
  final Slide? nextSlide;

  // Datos de la última respuesta (Feedback)
  final bool? lastWasCorrect;
  final int? lastPointsEarned;
  final String? feedbackMessage;

  Attempt({
    required this.attemptId,
    required this.playerName,
    required this.currentScore,
    required this.state,
    this.nextSlide,
    this.lastWasCorrect,
    this.lastPointsEarned,
    this.feedbackMessage,
  });

  factory Attempt.fromJson(Map<String, dynamic> json) {
    final slideData = json['nextSlide'] ?? json['firstSlide'];

    return Attempt(
      attemptId: json['attemptId'],
      playerName: json['playerName'] ?? 'Jugador',
      currentScore: json['currentScore'] ?? 0,
      state: json['state'] ?? 'IN_PROGRESS',
      lastWasCorrect: json['wasCorrect'],
      lastPointsEarned: json['pointsEarned'],
      feedbackMessage: json['feedbackMessage'],
      nextSlide: slideData != null
          ? Slide.fromJson(
              slideData,
              current: json['currentQuestionNumber'],
              total: json['totalQuestions'],
            )
          : null,
    );
  }
}
