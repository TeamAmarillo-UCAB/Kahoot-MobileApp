enum PlayerRole { host, player }

class PlayerInfo {
  final String playerId;
  final String username;
  final String nickname;
  final int totalScore;
  final PlayerRole role;

  const PlayerInfo({
    required this.playerId,
    required this.username,
    required this.nickname,
    required this.totalScore,
    required this.role,
  });

  bool get isHost => role == PlayerRole.host;

  PlayerInfo copyWith({
    String? playerId,
    String? username,
    String? nickname,
    int? totalScore,
    PlayerRole? role,
  }) {
    return PlayerInfo(
      playerId: playerId ?? this.playerId,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      totalScore: totalScore ?? this.totalScore,
      role: role ?? this.role,
    );
  }

  factory PlayerInfo.fromJson(Map<String, dynamic> json) {
    return PlayerInfo(
      playerId: json["playerId"] ?? "",
      username: json["username"] ?? "",
      nickname: json["nickname"] ?? "",
      totalScore: json["totalScore"] ?? 0,
      role: _roleFromString(json["role"] ?? "PLAYER"),
    );
  }

  static PlayerRole _roleFromString(String value) {
    switch (value.toUpperCase()) {
      case "HOST":
        return PlayerRole.host;
      default:
        return PlayerRole.player;
    }
  }

  static List<PlayerInfo> fromJsonList(List list) {
    return list.map((e) => PlayerInfo.fromJson(e)).toList();
  }
}
