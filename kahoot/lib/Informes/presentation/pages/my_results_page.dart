import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

// --- Infraestructura & Dominio ---
import '../../infrastructure/datasource/reports_datasource_impl.dart';
import '../../infrastructure/repositories/reports_repository_impl.dart';
import '../../application/usecases/get_my_results_history.dart';
import '../../domain/entities/result_summary.dart';

// --- BLoC ---
import '../blocs/reports_list_bloc/reports_list_bloc.dart';
import '../blocs/reports_list_bloc/reports_list_event.dart';
import '../blocs/reports_list_bloc/reports_list_state.dart';

// --- Widgets & Utils ---
import '../widgets/result_history_card.dart';
import '../widgets/animated_appear.dart';
import '../utils/app_colors.dart';

class MyResultsPage extends StatefulWidget {
  const MyResultsPage({super.key});

  @override
  State<MyResultsPage> createState() => _MyResultsPageState();
}

class _MyResultsPageState extends State<MyResultsPage> {
  late ReportsListBloc _bloc;
  final ScrollController _scrollController = ScrollController();

  // Lista manual para evitar errores de Locale en main.dart
  final List<String> _meses = [
    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Configuración Autosuficiente
    final dio = Dio(); 
    final datasource = ReportsDatasourceImpl(dio: dio);
    final repository = ReportsRepositoryImpl(datasource: datasource);

    _bloc = ReportsListBloc(
      getMyResultsHistory: GetMyResultsHistory(repository),
    );

    _bloc.add(LoadMyResults(limit: 15));
  }

  @override
  void dispose() {
    _bloc.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _bloc.add(LoadMoreResults());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  // --- SOLUCIÓN MANUAL AQUÍ ---
  Map<String, List<ResultSummary>> _groupResults(List<ResultSummary> list) {
    final Map<String, List<ResultSummary>> groups = {};
    final now = DateTime.now();

    for (var item in list) {
      String groupName;
      final diff = now.difference(item.completionDate).inDays;

      if (diff < 7 && now.month == item.completionDate.month) {
        groupName = "Esta semana";
      } else {
        // Obtenemos el nombre del mes de nuestra lista manual (mes 1 es índice 0)
        String nombreMes = _meses[item.completionDate.month - 1];
        groupName = "$nombreMes ${item.completionDate.year}";
      }

      if (!groups.containsKey(groupName)) {
        groups[groupName] = [];
      }
      groups[groupName]!.add(item);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          title: const Text(
            'Informes',
            style: TextStyle(
              color: AppColors.textBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primaryYellow,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<ReportsListBloc, ReportsListState>(
          builder: (context, state) {
            
            if (state.status == ListStatus.loading && state.results.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow));
            }

            if (state.status == ListStatus.failure && state.results.isEmpty) {
              return Center(child: Text("Error: ${state.errorMessage}", style: const TextStyle(color: Colors.white)));
            }

            if (state.results.isEmpty && state.status != ListStatus.loading) {
              return const Center(child: Text("No hay resultados.", style: TextStyle(color: Colors.white)));
            }

            final grouped = _groupResults(state.results);
            int globalIndex = 0;

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                for (var entry in grouped.entries) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = entry.value[index];
                        final delay = (globalIndex * 50).clamp(0, 500); 
                        globalIndex++;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: AnimatedAppear(
                            delayMs: delay,
                            child: ResultHistoryCard(summary: item),
                          ),
                        );
                      },
                      childCount: entry.value.length,
                    ),
                  ),
                ],
                if (!state.hasReachedMax)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primaryYellow)),
                    ),
                  ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
              ],
            );
          },
        ),
      ),
    );
  }
}