import 'slide.dart';

class Attempt {
  final String attemptId;
  final String state; // 'IN_PROGRESS', 'COMPLETED'
  final int currentScore;
  final Slide? nextSlide;

  Attempt({
    required this.attemptId,
    required this.state,
    required this.currentScore,
    this.nextSlide,
  });

  factory Attempt.fromJson(Map<String, dynamic> json) {
    // La API puede devolver 'nextSlide' o 'firstSlide' dependiendo del endpoint
    final slideData = json['nextSlide'] ?? json['firstSlide'];

    return Attempt(
      attemptId: json['attemptId'],
      state: json['state'] ?? 'IN_PROGRESS',
      currentScore: json['currentScore'] ?? 0,
      nextSlide: slideData != null ? Slide.fromJson(slideData) : null,
    );
  }
}
