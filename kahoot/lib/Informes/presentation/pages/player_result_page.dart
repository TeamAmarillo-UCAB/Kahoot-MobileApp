import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

// --- Infraestructura & Dominio ---
import '../../infrastructure/datasource/reports_datasource_impl.dart';
import '../../infrastructure/repositories/reports_repository_impl.dart';
import '../../application/usecases/get_player_result.dart';
import '../../application/usecases/get_session_report.dart'; // Necesario para instanciar el bloc aunque no se use aquí

// --- BLoC ---
import '../blocs/report_detail_bloc/report_detail_bloc.dart';
import '../blocs/report_detail_bloc/report_detail_event.dart';
import '../blocs/report_detail_bloc/report_detail_state.dart';

// --- Widgets & Utils ---
import '../widgets/animated_appear.dart';
import '../widgets/summary_stats_card.dart';
import '../widgets/question_result_item.dart';
import '../utils/app_colors.dart';
import '../../domain/entities/game_type.dart';

class PlayerResultPage extends StatefulWidget {
  final String id;
  final GameType gameType;
  final String title;

  const PlayerResultPage({
    super.key,
    required this.id,
    required this.gameType,
    required this.title,
  });

  @override
  State<PlayerResultPage> createState() => _PlayerResultPageState();
}

class _PlayerResultPageState extends State<PlayerResultPage> {
  late ReportDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    
    // 1. Configuración manual de Dependencias (Igual que en tu GamePage)
    // Usamos el Datasource y Repositorio de la épica actual (Reportes)
    final dio = Dio(); // O tu instancia configurada
    final datasource = ReportsDatasourceImpl(dio: dio);
    final repository = ReportsRepositoryImpl(datasource: datasource);

    // 2. Inicialización del BLoC
    _bloc = ReportDetailBloc(
      getPlayerResult: GetPlayerResult(repository),
      getSessionReport: GetSessionReport(repository),
    );

    // 3. Disparar evento de carga
    _bloc.add(LoadReportDetail(
      id: widget.id, 
      gameType: widget.gameType
    ));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark, // Fondo Oscuro
        appBar: AppBar(
          backgroundColor: AppColors.primaryYellow,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: BlocBuilder<ReportDetailBloc, ReportDetailState>(
          builder: (context, state) {
            
            // --- Carga ---
            if (state is ReportDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryYellow),
              );
            }

            // --- Error ---
            if (state is ReportDetailError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.errorRed, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: AppColors.textBlack,
                        ),
                        onPressed: () => _bloc.add(LoadReportDetail(
                          id: widget.id, 
                          gameType: widget.gameType
                        )),
                        child: const Text("Reintentar"),
                      )
                    ],
                  ),
                ),
              );
            }

            // --- Éxito ---
            if (state is PlayerResultLoaded) {
              final detail = state.detail;
              
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 8),
                  
                  // 1. Tarjeta de Resumen (Animada)
                  AnimatedAppear(
                    delayMs: 0,
                    child: SummaryStatsCard(detail: detail),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Título de sección
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 12),
                    child: Text(
                      "Tus Respuestas",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 2. Lista de Preguntas (Animadas en cascada)
                  ...List.generate(detail.questionResults.length, (index) {
                    final item = detail.questionResults[index];
                    // Delay incremental para efecto cascada (max 600ms)
                    final delay = (100 + (index * 100)).clamp(0, 600);
                    
                    return AnimatedAppear(
                      delayMs: delay,
                      child: QuestionResultCard(
                        item: item,
                        index: index,
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 20),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}