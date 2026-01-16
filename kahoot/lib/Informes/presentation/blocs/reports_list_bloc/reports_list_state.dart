import '../../../domain/entities/result_summary.dart';

enum ListStatus { initial, loading, success, failure }

class ReportsListState {
  final ListStatus status;
  final List<ResultSummary> results;
  final bool hasReachedMax;
  final int currentPage;
  final int totalPages;
  final int limit;
  final String errorMessage;

  const ReportsListState({
    this.status = ListStatus.initial,
    this.results = const [],
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.limit = 20,
    this.errorMessage = '',
  });

  // Método copyWith para inmutabilidad y actualización parcial
  ReportsListState copyWith({
    ListStatus? status,
    List<ResultSummary>? results,
    bool? hasReachedMax,
    int? currentPage,
    int? totalPages,
    int? limit,
    String? errorMessage,
  }) {
    return ReportsListState(
      status: status ?? this.status,
      results: results ?? this.results,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      limit: limit ?? this.limit,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}