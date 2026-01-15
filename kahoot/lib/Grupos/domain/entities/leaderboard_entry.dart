class LeaderboardEntry {
  final String userId;
  final String name;
  final int completedQuizzes;
  final int totalPoints;
  final int position;

  LeaderboardEntry({
    required this.userId,
    required this.name,
    this.completedQuizzes = 0,
    required this.totalPoints,
    this.position = 0,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] ?? '',
      name: json['name'] ?? 'Desconocido',
      completedQuizzes: json['completedQuizzes'] ?? 0,
      // La API a veces devuelve 'totalPoints' y a veces 'score' (en leaderboard de quiz)
      totalPoints: json['totalPoints'] ?? json['score'] ?? 0,
      position: json['position'] ?? 0,
    );
  }
}
