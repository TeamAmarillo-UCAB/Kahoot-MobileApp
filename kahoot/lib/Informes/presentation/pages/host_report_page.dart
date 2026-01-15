import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

// --- Infraestructura & Dominio ---
import '../../infrastructure/datasource/reports_datasource_impl.dart';
import '../../infrastructure/repositories/reports_repository_impl.dart';
import '../../application/usecases/get_player_result.dart';
import '../../application/usecases/get_session_report.dart';

// --- BLoC ---
import '../blocs/report_detail_bloc/report_detail_bloc.dart';
import '../blocs/report_detail_bloc/report_detail_event.dart';
import '../blocs/report_detail_bloc/report_detail_state.dart';

// --- Widgets & Utils ---
import '../widgets/animated_appear.dart';
import '../widgets/ranking_list_item.dart';
import '../widgets/accuracy_question_card.dart';
import '../utils/app_colors.dart';
import '../../domain/entities/game_type.dart';

class HostReportPage extends StatefulWidget {
  final String id; // SessionID
  final String title;

  const HostReportPage({
    super.key,
    required this.id,
    required this.title,
  });

  @override
  State<HostReportPage> createState() => _HostReportPageState();
}

class _HostReportPageState extends State<HostReportPage> with SingleTickerProviderStateMixin {
  late ReportDetailBloc _bloc;
  late TabController _tabController;
  
  // Estado local para el Dropdown (true = Puntos, false = Aciertos)
  bool _showPoints = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 1. Configuración de dependencias (Manual, igual que en PlayerResultPage)
    final dio = Dio();
    final datasource = ReportsDatasourceImpl(dio: dio);
    final repository = ReportsRepositoryImpl(datasource: datasource);

    // 2. Inicializar Bloc
    _bloc = ReportDetailBloc(
      getPlayerResult: GetPlayerResult(repository),
      getSessionReport: GetSessionReport(repository),
    );

    // 3. Cargar datos (Tipo HOST)
    _bloc.add(LoadReportDetail(
      id: widget.id, 
      gameType: GameType.multiplayerHost
    ));
  }
  
  @override
  void dispose() {
     _bloc.close();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.primaryYellow,
          title: Text(
            widget.title, 
            style: const TextStyle(
              color: AppColors.textBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: AppColors.textBlack),
          elevation: 0,
          // --- TabBar Integrado en AppBar ---
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.textBlack,
            unselectedLabelColor: Colors.black54,
            indicatorColor: AppColors.cardBrown,
            indicatorWeight: 4,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: const [
              Tab(text: "Informe"),
              Tab(text: "Exactitud"),
            ],
          ),
        ),
        body: BlocBuilder<ReportDetailBloc, ReportDetailState>(
          builder: (context, state) {
            
            if (state is ReportDetailLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow));
            }

            if (state is ReportDetailError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
            }

            if (state is HostReportLoaded) {
              final report = state.report;
              
              // Calculamos el puntaje máximo para las barras de progreso
              // (Si la lista está vacía, evitamos errores)
              final int maxScore = report.playerRanking.isNotEmpty 
                  ? report.playerRanking[0].score // Asumimos que viene ordenado por score descendente
                  : 1;
              
              final int totalQuestions = report.questionAnalysis.length;

              return TabBarView(
                controller: _tabController,
                children: [
                  // --- TAB 1: INFORME (Ranking) ---
                  Column(
                    children: [
                      // Header de la tabla con Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: const BoxDecoration(
                          color: Colors.black26, // Fondo sutil para el header
                          border: Border(bottom: BorderSide(color: Colors.white24)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Ranking Jugadores", 
                              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)
                            ),
                            
                            // Dropdown para alternar métricas
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.cardBrown,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<bool>(
                                  value: _showPoints,
                                  dropdownColor: AppColors.cardBrown,
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  items: const [
                                    DropdownMenuItem(value: true, child: Text("Puntos")),
                                    DropdownMenuItem(value: false, child: Text("Aciertos")),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _showPoints = val);
                                    }
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      
                      // Lista de Jugadores
                      Expanded(
                        child: report.playerRanking.isEmpty 
                          ? const Center(child: Text("Sin jugadores", style: TextStyle(color: Colors.white54)))
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 8),
                              itemCount: report.playerRanking.length,
                              itemBuilder: (context, index) {
                                final player = report.playerRanking[index];
                                return AnimatedAppear(
                                  delayMs: index * 50,
                                  child: RankingListItem(
                                    player: player,
                                    showPoints: _showPoints,
                                    maxScore: maxScore,
                                    totalQuestions: totalQuestions,
                                  ),
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                  
                  // --- TAB 2: EXACTITUD (Semáforo) ---
                  report.questionAnalysis.isEmpty
                    ? const Center(child: Text("Sin análisis de preguntas", style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: report.questionAnalysis.length,
                        itemBuilder: (context, index) {
                          final q = report.questionAnalysis[index];
                          
                          return AnimatedAppear(
                            delayMs: index * 50,
                            child: AccuracyQuestionCard(
                              question: q,
                              index: index,
                            ),
                          );
                        },
                      ),
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