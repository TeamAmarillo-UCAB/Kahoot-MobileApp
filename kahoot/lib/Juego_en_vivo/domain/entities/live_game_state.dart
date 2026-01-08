// lib/domain/entities/live_game_state.dart
import 'live_slide.dart';

class LiveGameState {
  final String phase;
  final LiveSlide? currentSlide;
  final List<dynamic>? players;
  final List<dynamic>? leaderboard;
  final bool? lastWasCorrect;
  final int? lastPointsEarned;
  final int? totalScore;
  final int? rank;
  final int? streak;
  final List<String>? correctAnswerIds;
  final String? feedbackMessage; // <--- Agregado
  final bool? isWinner;
  final bool? isPodium;
  final int? finalStreak;
  final dynamic podiumData;

  LiveGameState({
    required this.phase,
    this.currentSlide,
    this.players,
    this.leaderboard,
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
      lastWasCorrect: json['isCorrect'],
      lastPointsEarned: json['pointsEarned'],
      totalScore: json['totalScore'] ?? json['score'],
      rank: json['rank'],
      streak: json['streak'],
      feedbackMessage: json['message'], // <--- Mapeo de la llave del servidor
      correctAnswerIds: (json['correctAnswerIds'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      isWinner: json['isWinner'],
      isPodium: json['isPodium'],
      finalStreak: json['finalStreak'],
      podiumData: json['finalPodium'] ?? json['winner'],
    );
  }
}
