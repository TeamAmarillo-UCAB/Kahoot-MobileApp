// lib/Informes_Estadisticas/domain/entities/player_result_detail.dart

class PlayerResultDetail {
  final String kahootId;
  final String title;
  final String userId;
  final int finalScore;
  final int correctAnswers;
  final int totalQuestions;
  final int averageTimeMs;
  final int? rankingPosition; // Null en Singleplayer
  final List<QuestionResultItem> questionResults;

  PlayerResultDetail({
    required this.kahootId,
    required this.title,
    required this.userId,
    required this.finalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.averageTimeMs,
    this.rankingPosition,
    required this.questionResults,
  });

  factory PlayerResultDetail.fromJson(Map<String, dynamic> json) {
    final list = json['questionResults'] as List? ?? [];
    return PlayerResultDetail(
      kahootId: json['kahootId'] ?? '',
      title: json['title'] ?? 'Sin título',
      userId: json['userId'] ?? '',
      finalScore: json['finalScore'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      averageTimeMs: json['averageTimeMs'] ?? 0,
      rankingPosition: json['rankingPosition'],
      questionResults: list.map((e) => QuestionResultItem.fromJson(e)).toList(),
    );
  }
}

class QuestionResultItem {
  final int questionIndex;
  final String questionText;
  final bool isCorrect;
  final List<String> answerText; // Es una lista según el JSON
  final List<String> answerMediaId;
  final int timeTakenMs;

  QuestionResultItem({
    required this.questionIndex,
    required this.questionText,
    required this.isCorrect,
    required this.answerText,
    required this.answerMediaId,
    required this.timeTakenMs,
  });

  factory QuestionResultItem.fromJson(Map<String, dynamic> json) {
    return QuestionResultItem(
      questionIndex: json['questionIndex'] ?? 0,
      questionText: json['questionText'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      answerText: (json['answerText'] as List?)?.map((e) => e.toString()).toList() ?? [],
      answerMediaId: (json['answerMediaId'] as List?)?.map((e) => e.toString()).toList() ?? [],
      timeTakenMs: json['timeTakenMs'] ?? 0,
    );
  }
}