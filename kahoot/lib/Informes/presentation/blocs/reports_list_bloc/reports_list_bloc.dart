import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/usecases/get_my_results_history.dart';
import 'reports_list_event.dart';
import 'reports_list_state.dart';

class ReportsListBloc extends Bloc<ReportsListEvent, ReportsListState> {
  final GetMyResultsHistory getMyResultsHistory;

  ReportsListBloc({required this.getMyResultsHistory}) : super(const ReportsListState()) {
    
    // Handler para Carga Inicial
    on<LoadMyResults>(_onLoadMyResults);
    
    // Handler para Paginación (Siguiente página)
    on<LoadMoreResults>(_onLoadMoreResults);
  }

  Future<void> _onLoadMyResults(
    LoadMyResults event,
    Emitter<ReportsListState> emit,
  ) async {
    // 1. Emitimos estado de carga y reseteamos la lista
    emit(state.copyWith(
      status: ListStatus.loading,
      results: [],
      currentPage: 1,
      hasReachedMax: false,
      limit: event.limit,
    ));

    // 2. Llamada al caso de uso (Página 1)
    final result = await getMyResultsHistory(page: 1, limit: event.limit);

    if (result.isSuccessful()) {
      final data = result.getValue();
      
      // 3. Verificamos si ya alcanzamos el total de páginas desde el principio 
      final bool isMax = data.currentPage >= data.totalPages;

      emit(state.copyWith(
        status: ListStatus.success,
        results: data.results,
        currentPage: data.currentPage,
        totalPages: data.totalPages,
        hasReachedMax: isMax,
      ));
    } else {
      emit(state.copyWith(
        status: ListStatus.failure,
        errorMessage: result.getError().toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadMoreResults(
    LoadMoreResults event,
    Emitter<ReportsListState> emit,
  ) async {
    // Guards: Si ya llegamos al final o si estamos cargando, ignoramos el evento
    if (state.hasReachedMax || state.status == ListStatus.loading) return;

    // Nota visual: No cambiamos status a 'loading' aquí para no borrar la lista en UI.
    // Podrías tener un bool auxiliar 'isLoadingMore' si quieres mostrar un spinner pequeño abajo.

    final int nextPage = state.currentPage + 1;

    // Llamada al caso de uso (Siguiente Página)
    final result = await getMyResultsHistory(page: nextPage, limit: state.limit);

    if (result.isSuccessful()) {
      final data = result.getValue();

      if (data.results.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        // AQUI LA MAGIA: Concatenamos la lista vieja con la nueva
        final updatedList = List.of(state.results)..addAll(data.results);
        
        // Verificamos meta para saber si es la ultima 
        final bool isMax = data.currentPage >= data.totalPages;

        emit(state.copyWith(
          status: ListStatus.success,
          results: updatedList,
          currentPage: nextPage,
          totalPages: data.totalPages,
          hasReachedMax: isMax,
        ));
      }
    } else {
      // Si falla la paginación, mantenemos la lista vieja y mostramos error
      emit(state.copyWith(
        errorMessage: "Error al cargar más resultados",
        // Opcional: status: ListStatus.failure si quieres bloquear la UI, 
        // pero mejor solo mostrar un snackbar en la vista.
      ));
    }
  }
}