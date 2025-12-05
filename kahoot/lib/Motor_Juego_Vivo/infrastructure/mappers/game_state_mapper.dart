import '../../domain/entities/game_state.dart';

class GameStateMapper {
  static GameStateEntity fromWs(Map<String, dynamic> json) {
    return GameStateEntity.fromJson(json);
  }
}
