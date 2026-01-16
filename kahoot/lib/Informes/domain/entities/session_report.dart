class SessionReport {
  final String sessionId;
  final String title;
  final DateTime executionDate;
  final List<PlayerRankingItem> playerRanking;
  final List<QuestionAnalysisItem> questionAnalysis;

  SessionReport({
    required this.sessionId,
    required this.title,
    required this.executionDate,
    required this.playerRanking,
    required this.questionAnalysis,
  });

  factory SessionReport.fromJson(Map<String, dynamic> json) {
    final rankingList = json['playerRanking'] as List? ?? [];
    final analysisList = json['questionAnalysis'] as List? ?? [];

    return SessionReport(
      sessionId: json['sessionId'] ?? '',
      title: json['title'] ?? 'Sin título',
      executionDate: DateTime.tryParse(json['executionDate'] ?? '') ?? DateTime.now(),
      playerRanking: rankingList.map((e) => PlayerRankingItem.fromJson(e)).toList(),
      questionAnalysis: analysisList.map((e) => QuestionAnalysisItem.fromJson(e)).toList(),
    );
  }
}

class PlayerRankingItem {
  final int position;
  final String username;
  final int score;
  final int correctAnswers;

  PlayerRankingItem({
    required this.position,
    required this.username,
    required this.score,
    required this.correctAnswers,
  });

  factory PlayerRankingItem.fromJson(Map<String, dynamic> json) {
    return PlayerRankingItem(
      position: json['position'] ?? 0,
      username: json['username'] ?? 'Anónimo',
      score: json['score'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
    );
  }
}

class QuestionAnalysisItem {
  final int questionIndex;
  final String questionText;
  final double correctPercentage; // En el JSON viene como 0, 100, etc. (Number)

  QuestionAnalysisItem({
    required this.questionIndex,
    required this.questionText,
    required this.correctPercentage,
  });

  factory QuestionAnalysisItem.fromJson(Map<String, dynamic> json) {
    // Aseguramos que venga como double, a veces las APIs mandan int (0 o 100)
    final val = json['correctPercentage'];
    double parsed = 0.0;
    if (val is int) parsed = val.toDouble();
    if (val is double) parsed = val;

    return QuestionAnalysisItem(
      questionIndex: json['questionIndex'] ?? 0,
      questionText: json['questionText'] ?? '',
      correctPercentage: parsed,
    );
  }
}