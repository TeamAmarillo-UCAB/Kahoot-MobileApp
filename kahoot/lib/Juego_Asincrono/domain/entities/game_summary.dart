class GameSummary {
  final int totalScore;
  final int correctAnswers;
  final double accuracy;

  GameSummary({
    required this.totalScore,
    required this.correctAnswers,
    required this.accuracy,
  });

  factory GameSummary.fromJson(Map<String, dynamic> json) {
    return GameSummary(
      totalScore: _parseInt(json['totalScore'] ?? json['finalScore'] ?? 0),
      correctAnswers: _parseInt(
        json['correctAnswers'] ?? json['totalCorrect'] ?? 0,
      ),
      // Mapeamos 'accuracyPercentage' si existe
      accuracy: _parseDouble(
        json['accuracy'] ?? json['accuracyPercentage'] ?? 0.0,
      ),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
