
import '../../../domain/entities/game_type.dart';

abstract class ReportDetailEvent {}

class LoadReportDetail extends ReportDetailEvent {
  final String id; // attemptId o sessionId
  final GameType gameType;

  LoadReportDetail({required this.id, required this.gameType});
}