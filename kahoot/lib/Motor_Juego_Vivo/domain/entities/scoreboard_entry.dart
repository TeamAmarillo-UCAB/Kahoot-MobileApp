class ScoreboardEntry {
  final String playerId;
  final String username;
  final String nickname;
  final int totalPoints;
  final int position;

  const ScoreboardEntry({
    required this.playerId,
    required this.username,
    required this.nickname,
    required this.totalPoints,
    required this.position,
  });

  factory ScoreboardEntry.fromJson(Map<String, dynamic> json) {
    return ScoreboardEntry(
      playerId: json["playerId"] ?? "",
      username: json["username"] ?? "",
      nickname: json["nickname"] ?? "",
      totalPoints: json["totalPoints"] ?? 0,
      position: json["position"] ?? 0,
    );
  }

  static List<ScoreboardEntry> fromJsonList(List list) {
    return list.map((e) => ScoreboardEntry.fromJson(e)).toList();
  }
}
