class AssignedQuiz {
  final String assignmentId;
  final String quizId;
  final String title;
  final DateTime availableUntil;
  final String status; // 'COMPLETED', 'PENDING', etc.
  final int? score;

  AssignedQuiz({
    required this.assignmentId,
    required this.quizId,
    required this.title,
    required this.availableUntil,
    required this.status,
    this.score,
  });

  factory AssignedQuiz.fromJson(Map<String, dynamic> json) {
    final userResult = json['userResult'];
    return AssignedQuiz(
      assignmentId: json['assignmentId'] ?? '',
      quizId: json['quizId'] ?? '',
      title: json['title'] ?? 'Quiz sin título',
      availableUntil:
          DateTime.tryParse(json['availableUntil'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'PENDING',
      score: userResult != null ? userResult['score'] : null,
    );
  }
}
