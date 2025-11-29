enum GamePhase { lobby, question, results, end }

class GameState {
  final GamePhase phase;
  final List<dynamic> players;
  final Map<String, dynamic>? question;
  final List<dynamic> scoreboard;
  final bool loading;

  GameState({
    this.phase = GamePhase.lobby,
    this.players = const [],
    this.question,
    this.scoreboard = const [],
    this.loading = false,
  });

  GameState copyWith({
    GamePhase? phase,
    List<dynamic>? players,
    Map<String, dynamic>? question,
    List<dynamic>? scoreboard,
    bool? loading,
  }) =>
      GameState(
        phase: phase ?? this.phase,
        players: players ?? this.players,
        question: question ?? this.question,
        scoreboard: scoreboard ?? this.scoreboard,
        loading: loading ?? this.loading,
      );
}
