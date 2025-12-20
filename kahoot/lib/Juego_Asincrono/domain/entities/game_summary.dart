class GameSummary {
  final String attemptId;
  final int finalScore;
  final int totalCorrect;
  final int totalQuestions;
  final int accuracyPercentage;

  GameSummary({
    required this.attemptId,
    required this.finalScore,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.accuracyPercentage,
  });

  factory GameSummary.fromJson(Map<String, dynamic> json) {
    return GameSummary(
      attemptId: json['attemptId'],
      finalScore: json['finalScore'] ?? 0,
      totalCorrect: json['totalCorrect'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      accuracyPercentage: json['accuracyPercentage'] ?? 0,
    );
  }
}
