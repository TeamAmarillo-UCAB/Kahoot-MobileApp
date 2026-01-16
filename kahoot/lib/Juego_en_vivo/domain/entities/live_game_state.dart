import 'live_slide.dart';

class LiveGameState {
  final String phase;
  final LiveSlide? currentSlide;
  final List<dynamic>? players;
  final List<dynamic>? leaderboard;
  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? progress;
  final bool? lastWasCorrect;
  final int? lastPointsEarned;
  final int? totalScore;
  final int? rank;
  final int? streak;
  final List<String>? correctAnswerIds;
  final String? feedbackMessage;
  final bool? isWinner;
  final bool? isPodium;
  final int? finalStreak;
  final dynamic podiumData;

  LiveGameState({
    required this.phase,
    this.currentSlide,
    this.players,
    this.leaderboard,
    this.stats,
    this.progress,
    this.lastWasCorrect,
    this.lastPointsEarned,
    this.totalScore,
    this.rank,
    this.streak,
    this.correctAnswerIds,
    this.feedbackMessage,
    this.isWinner,
    this.isPodium,
    this.finalStreak,
    this.podiumData,
  });

  factory LiveGameState.fromJson(String phase, Map<String, dynamic> json) {
    return LiveGameState(
      phase: phase,
      currentSlide: json['currentSlideData'] != null
          ? LiveSlide.fromJson(json['currentSlideData'])
          : null,
      players: json['players'],
      leaderboard: json['leaderboard'],
      stats: json['stats'],
      progress: json['progress'],
      lastWasCorrect: json['isCorrect'],
      lastPointsEarned: json['pointsEarned'],
      totalScore: json['totalScore'] ?? json['score'],
      rank: json['rank'],
      streak: json['streak'],
      feedbackMessage: json['message'],
      correctAnswerIds: (json['correctAnswerIds'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      isWinner: json['isWinner'],
      isPodium: json['isPodium'],
      finalStreak: json['finalStreak'],
      podiumData: json['finalPodium'],
    );
  }

  LiveGameState copyWith({
    String? phase,
    LiveSlide? currentSlide,
    List<dynamic>? players,
    List<dynamic>? leaderboard,
    Map<String, dynamic>? stats,
    Map<String, dynamic>? progress,
    bool? lastWasCorrect,
    int? lastPointsEarned,
    int? totalScore,
    int? rank,
    int? streak,
    List<String>? correctAnswerIds,
    String? feedbackMessage,
    bool? isWinner,
    bool? isPodium,
    int? finalStreak,
    dynamic podiumData,
  }) {
    return LiveGameState(
      phase: phase ?? this.phase,
      currentSlide: currentSlide ?? this.currentSlide,
      players: players ?? this.players,
      leaderboard: leaderboard ?? this.leaderboard,
      stats: stats ?? this.stats,
      progress: progress ?? this.progress,
      lastWasCorrect: lastWasCorrect ?? this.lastWasCorrect,
      lastPointsEarned: lastPointsEarned ?? this.lastPointsEarned,
      totalScore: totalScore ?? this.totalScore,
      rank: rank ?? this.rank,
      streak: streak ?? this.streak,
      correctAnswerIds: correctAnswerIds ?? this.correctAnswerIds,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
      isWinner: isWinner ?? this.isWinner,
      isPodium: isPodium ?? this.isPodium,
      finalStreak: finalStreak ?? this.finalStreak,
      podiumData: podiumData ?? this.podiumData,
    );
  }
}
