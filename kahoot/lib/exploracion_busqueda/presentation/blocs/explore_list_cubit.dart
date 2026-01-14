import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kahoot/Creacion_edicion_quices/domain/entities/kahoot.dart';
import 'package:kahoot/exploracion_busqueda/domain/repositories/explore_repository.dart';
import 'package:kahoot/core/result.dart';

/// Estados para el listado de kahoots en exploración/búsqueda
enum ExploreListStatus { initial, loading, success, empty, failure }

class ExploreListState extends Equatable {
  final ExploreListStatus status;
  final List<Kahoot> source; // lista base cargada
  final List<Kahoot> items; // lista filtrada para mostrar
  final String query; // texto de búsqueda o categoría activa
  final String? error;

  const ExploreListState({
    this.status = ExploreListStatus.initial,
    this.source = const [],
    this.items = const [],
    this.query = '',
    this.error,
  });

  ExploreListState copyWith({
    ExploreListStatus? status,
    List<Kahoot>? source,
    List<Kahoot>? items,
    String? query,
    String? error,
  }) {
    return ExploreListState(
      status: status ?? this.status,
      source: source ?? this.source,
      items: items ?? this.items,
      query: query ?? this.query,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, source, items, query, error];
}

/// Cubit para manejar estados de búsqueda/listado de Kahoots
class ExploreListCubit extends Cubit<ExploreListState> {
  final ExploreRepository repository;
  String? _lastCategory;

  ExploreListCubit({required this.repository})
    : super(const ExploreListState());

  /// Carga la lista por categoría y prepara el estado para búsquedas locales
  Future<void> loadByCategory(String category) async {
    emit(
      state.copyWith(
        status: ExploreListStatus.loading,
        query: category,
        error: null,
      ),
    );
    _lastCategory = category;

    final Result<List<Kahoot>> result = await repository.getKahootsByCategory(
      category,
    );

    if (result.isSuccessful()) {
      final list = result.getValue();
      if (list.isEmpty) {
        emit(
          state.copyWith(
            status: ExploreListStatus.empty,
            source: list,
            items: list,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ExploreListStatus.success,
            source: list,
            items: list,
          ),
        );
      }
    } else {
      final err = result.getError();
      emit(
        state.copyWith(
          status: ExploreListStatus.failure,
          error: err.toString(),
        ),
      );
    }
  }

  /// Aplica filtro local por título usando el texto dado.
  void search(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      emit(state.copyWith(items: state.source, query: ''));
      return;
    }

    final q = normalized.toLowerCase();
    final filtered = state.source
        .where((k) => k.title.toLowerCase().contains(q))
        .toList();

    emit(
      state.copyWith(
        items: filtered,
        query: normalized,
        status: filtered.isEmpty
            ? ExploreListStatus.empty
            : ExploreListStatus.success,
      ),
    );
  }

  /// Limpia el texto de búsqueda y restablece la lista completa
  void clearSearch() {
    emit(
      state.copyWith(
        items: state.source,
        query: '',
        status: state.source.isEmpty
            ? ExploreListStatus.empty
            : ExploreListStatus.success,
      ),
    );
  }

  /// Recarga la última categoría (si existe)
  Future<void> refresh() async {
    final category = _lastCategory;
    if (category != null && category.isNotEmpty) {
      await loadByCategory(category);
    }
  }
}
