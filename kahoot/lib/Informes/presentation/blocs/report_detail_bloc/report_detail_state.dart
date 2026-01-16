
import '../../../domain/entities/player_result_detail.dart';
import '../../../domain/entities/session_report.dart';

abstract class ReportDetailState {}

class ReportDetailInitial extends ReportDetailState {}

class ReportDetailLoading extends ReportDetailState {}

// Estado para: Singleplayer y Multiplayer Player
class PlayerResultLoaded extends ReportDetailState {
  final PlayerResultDetail detail;
  PlayerResultLoaded(this.detail);
}

// Estado para: Multiplayer Host
class HostReportLoaded extends ReportDetailState {
  final SessionReport report;
  HostReportLoaded(this.report);
}

class ReportDetailError extends ReportDetailState {
  final String message;
  ReportDetailError(this.message);
}