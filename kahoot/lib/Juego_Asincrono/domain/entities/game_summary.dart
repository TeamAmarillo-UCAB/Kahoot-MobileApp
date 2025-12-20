class GameSummary {
  final String playerName;
  final int totalScore;
  final int correctAnswers;
  final int totalQuestions;

  GameSummary({
    required this.playerName,
    required this.totalScore,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  factory GameSummary.fromJson(Map<String, dynamic> json) {
    return GameSummary(
      playerName: json['playerName'] ?? 'Jugador',
      totalScore: json['totalScore'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
    );
  }
}
