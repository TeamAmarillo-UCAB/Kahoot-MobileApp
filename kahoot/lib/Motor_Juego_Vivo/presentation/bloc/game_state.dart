import 'package:equatable/equatable.dart';
import '../../domain/entities/game_state.dart';

class GameUiState extends Equatable {
  final bool isLoading;
  final String? errorMessage;

  /// Estado completo proveniente del servidor
  final GameStateEntity gameState;

  const GameUiState({
    required this.isLoading,
    required this.gameState,
    this.errorMessage,
  });

  factory GameUiState.initial() => GameUiState(
        isLoading: false,
        gameState: GameStateEntity.initial(),
        errorMessage: null,
      );

  GameUiState copyWith({
    bool? isLoading,
    GameStateEntity? gameState,
    String? errorMessage,
  }) {
    return GameUiState(
      isLoading: isLoading ?? this.isLoading,
      gameState: gameState ?? this.gameState,
      errorMessage: errorMessage,
    );
  }

  // Helpers para la UI
  bool get isLobby => gameState.phase == GamePhase.lobby;
  bool get isQuestion => gameState.phase == GamePhase.question;
  bool get isResults => gameState.phase == GamePhase.results;
  bool get isEnd => gameState.phase == GamePhase.end;

  @override
  List<Object?> get props => [isLoading, gameState, errorMessage];
}
