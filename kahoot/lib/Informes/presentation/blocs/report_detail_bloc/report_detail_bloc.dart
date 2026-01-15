import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/usecases/get_player_result.dart';
import '../../../application/usecases/get_session_report.dart';
import 'report_detail_event.dart';
import 'report_detail_state.dart';

class ReportDetailBloc extends Bloc<ReportDetailEvent, ReportDetailState> {
  final GetPlayerResult getPlayerResult;
  final GetSessionReport getSessionReport;

  ReportDetailBloc({
    required this.getPlayerResult,
    required this.getSessionReport,
  }) : super(ReportDetailInitial()) {
    
    on<LoadReportDetail>((event, emit) async {
      emit(ReportDetailLoading());

      // Lógica de derivación según el tipo de juego
      if (event.gameType.isHost) {
        // --- CASO ANFITRION ---
        final result = await getSessionReport(event.id);
        
        if (result.isSuccessful()) {
          emit(HostReportLoaded(result.getValue()));
        } else {
          emit(ReportDetailError(_cleanError(result.getError())));
        }

      } else {
        // --- CASO JUGADOR (Single o Multi) ---
        // Usamos el caso de uso inteligente que ya sabe manejar ambos sub-tipos
        final result = await getPlayerResult(
          id: event.id, 
          gameType: event.gameType
        );

        if (result.isSuccessful()) {
          emit(PlayerResultLoaded(result.getValue()));
        } else {
          emit(ReportDetailError(_cleanError(result.getError())));
        }
      }
    });
  }

  String _cleanError(dynamic error) {
    return error?.toString().replaceAll('Exception: ', '') ?? 'Error al cargar detalles';
  }
}