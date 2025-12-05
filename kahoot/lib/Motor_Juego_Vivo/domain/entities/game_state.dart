import 'player_info.dart';
import 'question_slide.dart';
import 'scoreboard_entry.dart';

/// Fases del juego enviadas por el backend:
/// "LOBBY", "QUESTION", "RESULTS", "END"
enum GamePhase { lobby, question, results, end }

extension GamePhaseX on GamePhase {
  /// Convierte `GamePhase.question` → `"QUESTION"`
  String toShortString() => toString().split('.').last.toUpperCase();

  /// Convierte `"QUESTION"` o `"question"` o `" Question "` → GamePhase.question
  static GamePhase fromString(String value) {
    final normalized = value.trim().toUpperCase();

    return GamePhase.values.firstWhere(
      (phase) => phase.toShortString() == normalized,
      orElse: () => GamePhase.lobby,
    );
  }
}

class GameStateEntity {
  final GamePhase phase;
  final List<PlayerInfo> players;
  final QuestionSlide? currentSlide;
  final List<ScoreboardEntry> scoreboard;

  final String? quizTitle;
  final String? quizMediaUrl;
  
  /// <── NUEVO
  final String? hostId;

  final int questionIndex;

  const GameStateEntity({
    required this.phase,
    required this.players,
    required this.questionIndex,
    this.currentSlide,
    this.scoreboard = const [],
    this.quizTitle,
    this.quizMediaUrl,
    this.hostId,    // <── NEW
  });

  factory GameStateEntity.initial() => const GameStateEntity(
        phase: GamePhase.lobby,
        players: [],
        questionIndex: 0,
        currentSlide: null,
        scoreboard: [],
        quizTitle: null,
        quizMediaUrl: null,
        hostId: null,      // <── NEW
      );

  GameStateEntity copyWith({
    GamePhase? phase,
    List<PlayerInfo>? players,
    QuestionSlide? currentSlide,
    List<ScoreboardEntry>? scoreboard,
    String? quizTitle,
    String? quizMediaUrl,
    int? questionIndex,
    String? hostId,     // <── NEW
  }) {
    return GameStateEntity(
      phase: phase ?? this.phase,
      players: players ?? this.players,
      currentSlide: currentSlide ?? this.currentSlide,
      scoreboard: scoreboard ?? this.scoreboard,
      quizTitle: quizTitle ?? this.quizTitle,
      quizMediaUrl: quizMediaUrl ?? this.quizMediaUrl,
      questionIndex: questionIndex ?? this.questionIndex,
      hostId: hostId ?? this.hostId,   // <── NEW
    );
  }

  // ────────────────────────────────────────────────
  // Helpers de estado
  // ────────────────────────────────────────────────

  bool get isQuestionActive => phase == GamePhase.question;
  bool get isShowingResults => phase == GamePhase.results;
  bool get isFinished => phase == GamePhase.end;

  // ────────────────────────────────────────────────
  // JSON Parser robusto para eventos como:
  // "game_state_update", "question_started", etc.
  // ────────────────────────────────────────────────

  factory GameStateEntity.fromJson(Map<String, dynamic> json) {
    return GameStateEntity(
      phase: GamePhaseX.fromString(json["state"] ?? "LOBBY"),
      players: PlayerInfo.fromJsonList(json["players"] ?? []),
      questionIndex: json["questionIndex"] ?? 0,
      quizTitle: json["quizTitle"],
      quizMediaUrl: json["quizMediaUrl"],
      hostId: json["hostId"],       // <── NEW
      currentSlide: json["currentSlideData"] == null
          ? null
          : QuestionSlide.fromJson(json["currentSlideData"]),
      scoreboard: ScoreboardEntry.fromJsonList(json["scoreboard"] ?? []),
    );
  }
}
