class Player {
  final String id;
  final String nickname;
  final int score;

  Player({required this.id, required this.nickname, required this.score});

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'] as String,
    nickname: json['nickname'] as String,
    score: json['score'] as int? ?? 0,
  );
}
