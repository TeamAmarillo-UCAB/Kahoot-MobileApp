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
    // 1. Buscamos el slide en cualquiera de sus posibles nombres
    final slideData = json['nextSlide'] ?? json['firstSlide'];

    return Attempt(
      // 2. Manejamos que a veces es 'id' (según tu JSON previo) y a veces 'attemptId'
      attemptId: json['attemptId'] ?? json['id'] ?? '',
      playerName: json['playerName'] ?? 'Jugador',
      // 3. El score cambia de nombre según el endpoint
      currentScore: json['currentScore'] ?? json['updatedScore'] ?? 0,
      // 4. El estado también cambia de nombre
      state: json['state'] ?? json['attemptState'] ?? 'IN_PROGRESS',
      lastWasCorrect: json['wasCorrect'],
      lastPointsEarned: json['pointsEarned'],
      feedbackMessage: json['feedbackMessage'],
      nextSlide: slideData != null
          ? Slide.fromJson(
              slideData,
              // 5. Si el JSON no trae estos datos, ponemos valores por defecto
              // para evitar el crash de 'null' en campos int.
              current: json['currentQuestionNumber'] ?? 1,
              total: json['totalQuestions'] ?? 1,
            )
          : null,
    );
  }
}
