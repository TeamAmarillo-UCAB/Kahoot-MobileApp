// Si lo corrigieras, debería ser algo como esto:
import '../../domain/entities/player_info.dart';

class PlayerMapper {
  static PlayerInfo fromWs(Map<String, dynamic> json) {
    return PlayerInfo.fromJson(json);
  }
}