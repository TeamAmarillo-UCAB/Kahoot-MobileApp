class ScoreboardEntry {
  final String playerId;
  final String nickname;
  final int score;
  final int position;

  ScoreboardEntry({
    required this.playerId,
    required this.nickname,
    required this.score,
    required this.position,
  });

  factory ScoreboardEntry.fromJson(Map<String, dynamic> json) => ScoreboardEntry(
    playerId: json['playerId'] as String,
    nickname: json['nickname'] as String,
    score: json['score'] as int,
    position: json['position'] as int? ?? 0,
  );
}
