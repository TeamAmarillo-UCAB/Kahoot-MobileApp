import 'slide.dart';

class Attempt {
  final String id;
  final String state;
  final int currentScore;
  final int lastPointsEarned;
  final Slide? nextSlide;
  final bool? lastWasCorrect;

  Attempt({
    required this.id,
    required this.state,
    required this.currentScore,
    this.lastPointsEarned = 0,
    this.nextSlide,
    this.lastWasCorrect,
  });

  bool get isFinished => state == 'COMPLETED';

  factory Attempt.fromJson(Map<String, dynamic> json) {
    final slideData = json['nextSlide'] ?? json['firstSlide'];

    return Attempt(
      id: json['attemptId'] ?? '',
      state: json['state'] ?? json['attemptState'] ?? 'IN_PROGRESS',
      currentScore: json['currentScore'] ?? json['updatedScore'] ?? 0,
      lastPointsEarned: json['pointsEarned'] ?? 0,
      lastWasCorrect: json['wasCorrect'],
      nextSlide: slideData != null ? Slide.fromJson(slideData) : null,
    );
  }
}
