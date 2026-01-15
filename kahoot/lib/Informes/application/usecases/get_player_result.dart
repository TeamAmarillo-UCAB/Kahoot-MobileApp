
import '../../../core/result.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/entities/player_result_detail.dart';
import '../../domain/entities/game_type.dart';

class GetPlayerResult {
  final ReportsRepository repository;

  GetPlayerResult(this.repository);

  /// Obtiene el detalle del resultado basándose en el tipo de juego.
  /// [id] puede ser sessionId (Multi) o attemptId (Single).
  Future<Result<PlayerResultDetail>> call({
    required String id,
    required GameType gameType,
  }) async {
    switch (gameType) {
      case GameType.singleplayer:
        return await repository.getSingleplayerResult(id);
      
      case GameType.multiplayerPlayer:
        return await repository.getMultiplayerResult(id);
      
      case GameType.multiplayerHost:
        // Técnicamente un Host no debería llamar a este caso de uso 
        // para ver "sus respuestas" de la misma forma, 
        // pero si la lógica cambiara, se manejaría aquí.
        return Result.makeError(Exception("El anfitrión debe usar el reporte de sesión"));
        
      case GameType.unknown:
        return Result.makeError(Exception("Tipo de juego desconocido o no soportado"));
    }
  }
}