class LivePlayer {
  final String id;
  final String nickname;
  final int score;
  final int rank;

  LivePlayer({
    required this.id,
    required this.nickname,
    required this.score,
    required this.rank,
  });

  factory LivePlayer.fromJson(Map<String, dynamic> json) {
    return LivePlayer(
      id: json['playerId']?.toString() ?? json['id']?.toString() ?? '',
      nickname: json['nickname'] ?? '',
      score: json['score'] ?? 0,
      rank: json['rank'] ?? 0,
    );
  }
}
